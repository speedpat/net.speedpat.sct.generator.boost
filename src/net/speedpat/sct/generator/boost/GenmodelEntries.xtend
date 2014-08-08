package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.yakindu.base.types.Parameter
import org.yakindu.sct.generator.core.types.ICodegenTypeSystemAccess
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgen.FeatureParameterValue
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.OperationDefinition

class GenmodelEntries extends org.yakindu.sct.generator.c.GenmodelEntries {

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

	def operations(Scope it) {
		declarations.filter(typeof(OperationDefinition));
	}

	def hasOperations(Scope it) {
		!operations.isEmpty;
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
	«name.asIdentifier»*'''

	def handlerInterfaces(ExecutionFlow it) {
		for (s : scopes) {
			switch (s) {
				InterfaceScope: s.handlerInterfaces
			}
		}
	}

}
