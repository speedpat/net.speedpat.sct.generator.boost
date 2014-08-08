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

class StatemachineInterface {
	@Inject extension Naming
	@Inject extension GenmodelEntries
	@Inject extension INamingService

	def generateStatemachineInterfaceHpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {
		if (fsa instanceof SimpleResourceFileSystemAccess) {
			fsa.generateFile(flow.statemachineInterfaceModule.h.filename, flow.statemachineInterfaceHContents(entry))
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
		
		«FOR Scope it : scopes»
			«handlerInterface»
		«ENDFOR»
		
		class «name.asIdentifier»{
		public:
			virtual ~«name.asIdentifier»() {};
			virtual void enter() = 0;
			«FOR Scope it : scopes»
				«eventVirtualMethod»
			«ENDFOR»
		};
		
		«name.asIdentifier»* createStatemachine(«handlerInterfaceTypes»);
		
		} /* namespace «entry.cppNamespace» */
			
		#endif /* «statemachineInterfaceModule.define»_H_ */
	'''

	def handlerInterface(Scope scope) {
		switch (scope) {
			InterfaceScope: scope.handlerInterface
		}
	}
	




	def handlerInterface(InterfaceScope it) '''
		class «name.asIdentifier» {
		public:
			virtual ~«name.asIdentifier»();
			«FOR OperationDefinition it : it.operations»
				virtual void «name»(«parameterList») = 0;
			«ENDFOR»
		};
	'''



	def eventVirtualMethod(Scope scope) {
		switch (scope) {
			InterfaceScope: scope.eventVirtualMethod
		}
	}

	def eventVirtualMethod(InterfaceScope it) '''
		«FOR Event it : events»
			«eventVirtualMethod»
		«ENDFOR»
	'''

	def eventVirtualMethod(Event it) '''
		virtual void «name»() = 0;
	'''

}
