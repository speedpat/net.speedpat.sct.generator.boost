/**
 * Copyright (c) 2014 Patrick Heeb.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
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
