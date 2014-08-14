package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.yakindu.base.types.Parameter
import org.yakindu.sct.generator.core.types.ICodegenTypeSystemAccess
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.ExecutionState
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.stext.stext.EventDefinition
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.OperationDefinition

class Naming extends org.yakindu.sct.generator.cpp.Naming {

	@Inject extension Navigation
	@Inject extension ICodegenTypeSystemAccess
	@Inject extension INamingService

	def eventsModule(ExecutionFlow it) {
		name + '_events'
	}

	def statesModule(ExecutionFlow it) {
		name + '_states'
	}

	def statemachineInterfaceModule(ExecutionFlow it) {
		name + '_statemachine_interface'
	}

	def statemachineModule(ExecutionFlow it) {
		name + '_statemachine'
	}

	def eventsModule(Scope it) {
		switch (it) {
			InterfaceScope: eventsModule
		}
	}

	def filename(String it) {
		it.toLowerCase
	}

	override h(String it) {
		it + ".hpp"
	}

	def baseStateModule(ExecutionFlow it) {
		'base_state'
	}
	
	def statemachineName(ExecutionFlow it) {
		name.asIdentifier.toFirstUpper
	}

	def statemachineLogic(ExecutionFlow it) {
		statemachineName + "Logic"
	}
	
	def statemachineBackend(ExecutionFlow it) {
		statemachineName + "Backend"
	}
	
	def statemachineInterfaceName(ExecutionFlow it) {
		"I" + statemachineName;
	}
	

	def debugTypeModule(ExecutionFlow it) {
		'debug_type'
	}

	def eventsModule(InterfaceScope it) {
		return name + '_events'
	}

	def eventValueParams(EventDefinition it) {
		if (hasValue)
			type.targetLanguageName + ' value;'
		else
			''
	}

	def stateName(String it) {
		asIdentifier
	}

	def handlerInterfaceMemberName(InterfaceScope it) '''
	m_«name.toFirstUpper.asIdentifier»'''

	def operationParams(Parameter it) {
		type.targetLanguageName + ' ' + name
	}
	
	def stateTypeName(ExecutionState it) {
		shortName.stateName
	}
	
	def stateTypeQualifiedName(ExecutionState it) {
		it.superScope.name.asIdentifier + "::" + stateTypeName
		
	}
	
	def eventTypeQualifiedName(EventDefinition it) {
		"events::" + it.scope?.scopeNamespaceQualifier + it.name.asIdentifier
	}
	
	def eventTypeQualifiedName(Event it) {
		"events::" + it.scope?.scopeNamespaceQualifier + it.name.asIdentifier
	}
	
	def scopeNamespaceName(Scope it) {
		scopeName.asIdentifier.toLowerCase
	}
	def scopeNamespaceQualifier(Scope it) {
		scopeNamespaceName + "::"
	}
	
	def dispatch scopeName(Scope s) {
		""
	}
	
	def dispatch scopeName(InterfaceScope s) {
		s.name
	}
	
	def asFunction(Event it) {
		name.asIdentifier.toFirstLower	
	}
	 
}
