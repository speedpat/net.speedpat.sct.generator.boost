package net.speedpat.sct.generator.boost;

import static net.speedpat.sct.generator.boost.IFeatureConstants.CPP_NAMESPACE;
import static net.speedpat.sct.generator.boost.IFeatureConstants.LIBRARY_NAME;

import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.ecore.EObject;
import org.yakindu.sct.generator.core.features.AbstractDefaultFeatureValueProvider;
import org.yakindu.sct.model.sgen.FeatureParameterValue;
import org.yakindu.sct.model.sgen.FeatureTypeLibrary;
	
/**
 * Default value provider for Boost.MSM Generator feature library
 */
public class BoostGeneratorDefaultValueProvider extends AbstractDefaultFeatureValueProvider {


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

	public IStatus validateParameterValue(FeatureParameterValue parameterValue) {
		String parameterName = parameterValue.getParameter().getName();
		
		// TODO implement validation
		// return error("Illegal parameter value");
		return Status.OK_STATUS;
	}
}
