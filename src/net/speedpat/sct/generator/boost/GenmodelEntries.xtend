package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.yakindu.base.types.Parameter
import org.yakindu.sct.generator.core.types.ICodegenTypeSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.ExecutionRegion
import org.yakindu.sct.model.sexec.ExecutionState
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgen.FeatureParameterValue
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.OperationDefinition
import java.util.ArrayList

class GenmodelEntries extends org.yakindu.sct.generator.c.GenmodelEntries {

	@Inject extension Naming
	@Inject extension ICodegenTypeSystemAccess
	@Inject extension INamingService

	def private getGeneratorFeature(GeneratorEntry it) {
		getFeatureConfiguration(IFeatureConstants::GENERATE)
	}

	def private FeatureParameterValue getCppNamespaceParameter(GeneratorEntry it) {
		generatorFeature?.getParameterValue(IFeatureConstants::CPP_NAMESPACE)
	}

	def getCppNamespace(GeneratorEntry it) {
		if (cppNamespaceParameter != null) {
			return cppNamespaceParameter.stringValue;
		}
		return null
	}

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
		«FOR it: interfaces SEPARATOR ", "»«handlerInterfaceParameterName»«ENDFOR»'''
	
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
}
