package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.base.types.Parameter
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.OperationDefinition
import org.yakindu.sct.generator.cpp.Navigation

class StatemachineInterface {
	@Inject extension Naming
	@Inject extension GenmodelEntries
	@Inject extension INamingService
	@Inject extension Navigation

	def generateStatemachineInterfaceHpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {
		if (fsa instanceof SimpleResourceFileSystemAccess) {
			fsa.generateFile(flow.statemachineInterfaceModule.h.filename, flow.statemachineInterfaceHContents(entry))
			fsa.generateFile(flow.statemachineModule.cpp.filename, flow.statemachineInterfaceCppContents(entry))
		}
	}

	def statemachineInterfaceHContents(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «statemachineInterfaceModule.define»_H_
		#define «statemachineInterfaceModule.define»_H_
		
		«FOR Scope it : scopes»		
			#include "«eventsModule.filename.h»"
		«ENDFOR»
		
		namespace «entry.cppNamespace» {
		
		«FOR InterfaceScope it : interfaces»
			«handlerInterface»
		«ENDFOR»
		
		class «statemachineInterfaceName»{
		public:
			virtual ~«statemachineInterfaceName»() {};
			virtual void enter() = 0;
			«FOR InterfaceScope it : interfaces»
				«eventPureVirtualMethods»
			«ENDFOR»
		};
		
		«statemachineInterfaceName»* createStatemachine(«handlerInterfaceTypes»);
		
		} /* namespace «entry.cppNamespace» */
			
		#endif /* «statemachineInterfaceModule.define»_H_ */
	'''
	
	def statemachineInterfaceCppContents(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#include "«statemachineInterfaceModule.h.filename»"
		
		namespace «entry.cppNamespace» {
			
		«FOR InterfaceScope it : interfaces»
		«handlerInterfaceTypeName»::~«handlerInterfaceTypeName»()
		{
		}
		«ENDFOR»
			
		} /* «entry.cppNamespace» */
	'''
	
	def handlerInterface(InterfaceScope it) '''
		class «handlerInterfaceTypeName» {
		public:
			virtual ~«handlerInterfaceTypeName»();
			«FOR OperationDefinition it : it.operations»
				virtual void «name»(«parameterList») = 0;
			«ENDFOR»
		};
	'''





}
