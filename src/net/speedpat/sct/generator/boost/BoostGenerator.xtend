package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.IExecutionFlowGenerator
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Statechart

class BoostGenerator implements IExecutionFlowGenerator {

	@Inject extension Events
	@Inject extension Types
	@Inject extension States
	@Inject extension StatemachineInterface
	@Inject extension StatemachineHeader

	override generate(ExecutionFlow flow, GeneratorEntry entry, IFileSystemAccess fsa) {
		flow.generateTypesHpp(flow.sourceElement as Statechart, fsa, entry)
		flow.generateEventsHpp(flow.sourceElement as Statechart, fsa, entry)
		flow.generateStatesHpp(flow.sourceElement as Statechart, fsa, entry)
		flow.generateStatemachineInterfaceHpp(flow.sourceElement as Statechart, fsa, entry)
		flow.generateStatemachineHeaderHpp(flow.sourceElement as Statechart, fsa, entry)

	}

}
