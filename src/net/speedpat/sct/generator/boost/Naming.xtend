package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.yakindu.sct.generator.core.types.ICodegenTypeSystemAccess
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.stext.stext.EventDefinition
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.base.types.Parameter

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
	
	def operationParams(Parameter it) {
		type.targetLanguageName + ' ' + name
	}
	
	def stateName(String it) {
		asIdentifier
	}
}
