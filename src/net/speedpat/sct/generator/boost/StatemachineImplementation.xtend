package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.stext.stext.EventDefinition
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.OperationDefinition

class StatemachineImplementation {
	@Inject extension Naming
	@Inject extension GenmodelEntries
	@Inject extension INamingService
	@Inject extension Navigation
	@Inject extension FlowCode
	@Inject extension Transitions

	def generateStatemachineImplementationCpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa,
		GeneratorEntry entry) {
		if (fsa instanceof SimpleResourceFileSystemAccess) {
			fsa.generateFile(flow.statemachineModule.cpp.filename, flow.generateStatemachineImplementationCpp(entry))
		}

	}

	def generateStatemachineImplementationCpp(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#include "«flow.statemachineModule.h.filename»"
		
		namespace «entry.cppNamespace» {
			
		«statemachineInterfaceName»* createStatemachine(«handlerInterfaceTypes») 
		{
			return new «statemachineBackend»(«handlerInterfaceParameterList»);
		}
		
		«statemachineLogic»::«statemachineLogic»(«handlerInterfaceTypes»)
		«FOR it: interfaces BEFORE ":" SEPARATOR ","» «handlerInterfaceMemberName»(«handlerInterfaceParameterName») «ENDFOR»
		{
		}

		«statemachineLogic»::~«statemachineLogic»()
		{
		}
		
		«actionFunctions»
		
		
		«statemachineBackend»::«statemachineBackend»(«handlerInterfaceTypes»)
		: boost::msm::back::state_machine<«statemachineLogic»>(«handlerInterfaceParameterList»)
		{
		}
		
		«statemachineBackend»::~«statemachineBackend»()
		{
		}

		«FOR InterfaceScope scope : interfaces»
		
		«FOR Event event: scope.events»
		void «statemachineBackend»::«event.name»()
		{
			process_event(«event.eventTypeQualifiedName»());
		}
		«ENDFOR»
		«ENDFOR»
		
		void «statemachineBackend»::enter()
		{
			start();
		}
		
		} /* namespace «entry.cppNamespace» */
		'''
	
	def actionFunctions(ExecutionFlow flow) {
		var table = flow.transitions
		'''
		«FOR it: table»
			«action?.definition(event, flow)»
		«ENDFOR»
		'''
	}
	
	def definition(OperationDefinition it, EventDefinition event, ExecutionFlow flow) {
		var interfaceScope = scope as InterfaceScope;
	'''
	void «flow.statemachineLogic»::«asFunction»(const «event.eventTypeQualifiedName»& event)
	{
		//«interfaceScope.handlerInterfaceMemberName»->«asFunction»(event);
		«interfaceScope.handlerInterfaceMemberName»->«asFunction»();
	}
	'''
	
	}

}
