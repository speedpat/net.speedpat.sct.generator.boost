/**
 * Copyright (c) 2014 Patrick Heeb.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package net.speedpat.sct.generator.boost;

import static net.speedpat.sct.generator.boost.IFeatureConstants.CPP_NAMESPACE;
import static net.speedpat.sct.generator.boost.IFeatureConstants.LIBRARY_NAME;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.ecore.EObject;
import org.yakindu.sct.generator.c.features.CFeatureConstants;
import org.yakindu.sct.generator.core.features.AbstractDefaultFeatureValueProvider;
import org.yakindu.sct.model.sgen.FeatureParameterValue;
import org.yakindu.sct.model.sgen.FeatureTypeLibrary;
	
/**
 * Default value provider for Boost.MSM Generator feature library
 */
public class BoostGeneratorDefaultValueProvider extends AbstractDefaultFeatureValueProvider {

	private static final String VALID_IDENTIFIER_REGEX = "[_a-zA-Z][_a-zA-Z0-9]*";

	public boolean isProviderFor(FeatureTypeLibrary library) {
		return library.getName().equals(LIBRARY_NAME);
	}

	@Override
	protected void setDefaultValue(FeatureParameterValue parameterValue,
			EObject context) {
		String parameterName = parameterValue.getParameter().getName();
		if (CPP_NAMESPACE.equals(parameterName)) {
			parameterValue.setValue("stm");
		}
	}

	public IStatus validateParameterValue(FeatureParameterValue parameter) {
		String parameterName = parameter.getParameter().getName();
		if (CFeatureConstants.PARAMETER_MODULE_NAME.equals(parameterName)) {
			if (!parameter.getStringValue().matches(VALID_IDENTIFIER_REGEX)) {
				return error("Invalid module name");
			}
		}
		return Status.OK_STATUS;
	}
}
