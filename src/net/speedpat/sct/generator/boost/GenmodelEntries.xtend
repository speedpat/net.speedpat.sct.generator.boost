package net.speedpat.sct.generator.boost

import org.yakindu.sct.model.sgen.FeatureParameterValue
import org.yakindu.sct.model.sgen.GeneratorEntry

class GenmodelEntries extends org.yakindu.sct.generator.c.GenmodelEntries {

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
}
