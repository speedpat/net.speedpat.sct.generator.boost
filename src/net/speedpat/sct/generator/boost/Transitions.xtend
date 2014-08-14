package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import java.util.ArrayList
import java.util.List
import java.util.Vector
import org.yakindu.base.expressions.expressions.ElementReferenceExpression
import org.yakindu.base.expressions.expressions.Expression
import org.yakindu.base.expressions.expressions.FeatureCall
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.Check
import org.yakindu.sct.model.sexec.EnterState
import org.yakindu.sct.model.sexec.Execution
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.ExecutionRegion
import org.yakindu.sct.model.sexec.ExecutionState
import org.yakindu.sct.model.sexec.If
import org.yakindu.sct.model.sexec.Sequence
import org.yakindu.sct.model.sexec.Step
import org.yakindu.sct.model.sgraph.Declaration
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.stext.stext.EventDefinition
import org.yakindu.sct.model.stext.stext.OperationDefinition

class Transitions {
	@Inject extension Navigation
	@Inject extension FlowCode
	@Inject extension Naming

	static class TransitionTableEntry {
		public EventDefinition event;
		public ExecutionState sourceState;
		public ExecutionState targetState;
		public OperationDefinition action;

	}

	def dispatch List<Transitions.TransitionTableEntry> transitions(ExecutionFlow flow) {
		var entries = new Vector<Transitions.TransitionTableEntry>
		for (region : flow.regions) {
			entries.addAll(region.transitions)
		}
		entries;
	}

	def dispatch List<Transitions.TransitionTableEntry> transitions(ExecutionRegion region) {
		var entries = new Vector<Transitions.TransitionTableEntry>
		for (state : region.states) {
			entries.addAll(state.transitions)
		}
		entries;
	}

	def dispatch List<Transitions.TransitionTableEntry> transitions(ExecutionState it) {
		var list = new ArrayList<Transitions.TransitionTableEntry>
		for (Step step : reactSequence.steps)
			transitions(list, step)

		return list;
	}

	def dispatch List<Transitions.TransitionTableEntry> transitions(ExecutionState state,
		List<Transitions.TransitionTableEntry> entries, Step step) {
	}

	def dispatch List<Transitions.TransitionTableEntry> transitions(ExecutionState state,
		List<Transitions.TransitionTableEntry> entries, If condition) {
		var entry = new Transitions.TransitionTableEntry
		entry.sourceState = state;
		entry.transition(condition.check)
		entry.transition(condition.thenStep)
		entries.add(entry)
		if(condition.elseStep != null) state.transitions(entries, condition.elseStep)
		return entries;
	}

	def dispatch List<Transitions.TransitionTableEntry> transitions(ExecutionState state,
		List<Transitions.TransitionTableEntry> entries, Sequence seq) {
		for (Step s : seq.steps)
			transitions(state, entries, s)

		return entries;
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry, Check c) {
		entry.transition(c.condition)
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry, Step s) {
		entry;
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry, Sequence seq) {
		for (Step s : seq.steps) {
			entry.transition(s);
		}
		return entry;
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry, EnterState state) {
		entry.targetState = state.state;
		return entry;
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry, Execution exec) {
		entry.transition(exec.statement)
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry, Expression exec) {
		entry
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry, FeatureCall exec) {
		entry.transition(exec.definition);
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry,
		OperationDefinition exec) {
		entry.action = exec;
		return entry;
	}

	def dispatch Transitions.TransitionTableEntry transition(Transitions.TransitionTableEntry entry,
		ElementReferenceExpression ref) {
		ref.transition(entry, ref.definition)
	}

	def dispatch Transitions.TransitionTableEntry transition(ElementReferenceExpression re,
		Transitions.TransitionTableEntry entry, Declaration target) {
		return entry;
	}

	def dispatch Transitions.TransitionTableEntry transition(ElementReferenceExpression ref,
		Transitions.TransitionTableEntry entry, Event event) {
		entry.event = event as EventDefinition;
		return entry;
	}

	def hasAction(Transitions.TransitionTableEntry it) {
		action != null
	}

	def transition(Transitions.TransitionTableEntry it) '''
	«row»<«sourceState.stateTypeQualifiedName», «event.eventTypeQualifiedName», «targetState.stateTypeQualifiedName» «action?.
		row»>'''

	def row(Transitions.TransitionTableEntry it) '''
	«IF hasAction»a_row«ELSE»_row«ENDIF»'''

	def CharSequence row(OperationDefinition it) {
		", &" + it.flow.statemachineLogic + "::" + it.asFunction
	}

	def declaration(OperationDefinition it, EventDefinition event) '''
		virtual void «asFunction»(const «event.eventTypeQualifiedName»&);
	'''

}
