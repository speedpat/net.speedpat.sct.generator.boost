/**
 * Copyright (c) 2014 Patrick Heeb.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.yakindu.base.types.Parameter
import org.yakindu.sct.generator.core.types.ICodegenTypeSystemAccess
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.Call
import org.yakindu.sct.model.sexec.EnterState
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.ExecutionRegion
import org.yakindu.sct.model.sexec.ExecutionState
import org.yakindu.sct.model.sexec.ExitState
import org.yakindu.sct.model.sexec.Sequence
import org.yakindu.sct.model.sexec.Step
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.OperationDefinition

class FlowCode extends org.yakindu.sct.generator.cpp.FlowCode {

	@Inject extension Naming
	@Inject extension Navigation
	@Inject extension INamingService

	@Inject extension ICodegenTypeSystemAccess

	override dispatch CharSequence code(Call it) '''«step.shortName»();'''

	override dispatch CharSequence code(Sequence it) '''
		/* «it.class.name» */
		«IF !steps.nullOrEmpty»«stepComment»«ENDIF»
		«FOR s : steps»
			«s.code»
		«ENDFOR»
	'''

	override dispatch CharSequence code(EnterState it) '''
		«state.shortName»;
	'''

	override def dispatch CharSequence code(ExitState it) '''
		«state.shortName»;
	'''

	def operationParams(Parameter it) {
		type.targetLanguageName + ' ' + name
	}

	def parameterList(OperationDefinition it) '''
		«FOR it : parameters SEPARATOR ', '»
			«operationParams»
		«ENDFOR»
	'''

	def interfaces(ExecutionFlow it) {
		scopes.filter(typeof(InterfaceScope));
	}

	def handlerInterfaceTypes(ExecutionFlow it) '''
	«FOR it : interfaces SEPARATOR ", "»«handlerInterfaces»«ENDFOR»'''

	def handlerInterfaces(InterfaceScope it) '''
	«handlerInterfaceTypeName»* «handlerInterfaceParameterName»'''

	def handlerInterfaceTypeName(InterfaceScope it) {
		name.asIdentifier
	}

	def handlerInterfaceParameterName(InterfaceScope it) {
		"_" + name.asIdentifier.toLowerCase;
	}

	def handlerInterfaceParameterList(ExecutionFlow it) '''
	«FOR it : interfaces SEPARATOR ", "»«handlerInterfaceParameterName»«ENDFOR»'''

	def handlerInterfaces(ExecutionFlow it) {
		for (s : scopes) {
			switch (s) {
				InterfaceScope: s.handlerInterfaces
			}
		}
	}

	def stateTypes(ExecutionRegion it) {
		'''
			namespace «name.asIdentifier» {
			«FOR ExecutionState it : states»
				«stateType»
			«ENDFOR» 
			} /* «name.asIdentifier» */
		'''
	}

	def states(ExecutionRegion it) {
		it.execution_flow.states.filter[state|state.superScope === it]
	}

	def stateType(ExecutionState it) {
		'''
			struct «stateTypeName» : base_state<«stateTypeName»> 
			{
			};
		'''
	}

	def eventVirtualMethods(InterfaceScope it) '''
		«FOR Event it : events»
			«eventVirtualMethod»
		«ENDFOR»
	'''

	def eventPureVirtualMethods(InterfaceScope it) '''
		«FOR Event it : events»
			«eventPureVirtualMethod»
		«ENDFOR»
	'''

	def eventVirtualMethod(Event it) '''
		virtual void «asFunction»();
	'''

	def eventPureVirtualMethod(Event it) '''
		virtual void «asFunction»() = 0;
	'''

	def CharSequence enterStatesList(ExecutionFlow it) '''
	«FOR it : enterSequences.defaultSequence.enterStates SEPARATOR ","»
		«state.stateTypeQualifiedName»«ENDFOR»'''

	def dispatch EList<EnterState> enterStates(Sequence it) {
		var list = new BasicEList<EnterState>();
		for (it : it.steps)
			list.addAll(it.enterStates)

		return list
	}

	def dispatch EList<EnterState> enterStates(Step it) {
		return new BasicEList<EnterState>();
	}

	def dispatch EList<EnterState> enterStates(EnterState it) {
		var list = new BasicEList<EnterState>();
		list.add(it)
		return list
	}

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
