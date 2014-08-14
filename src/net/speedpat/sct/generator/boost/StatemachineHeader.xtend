package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.EnterState
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.Sequence
import org.yakindu.sct.model.sexec.Step
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.stext.stext.EventDefinition
import org.yakindu.sct.model.stext.stext.InterfaceScope
import org.yakindu.sct.model.stext.stext.OperationDefinition

class StatemachineHeader {
	@Inject extension Naming
	@Inject extension GenmodelEntries
	@Inject extension INamingService
	@Inject extension Navigation
	@Inject extension FlowCode
	@Inject extension Transitions
	
	def generateStatemachineHeaderHpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {
		if (fsa instanceof SimpleResourceFileSystemAccess) {
			fsa.generateFile(flow.statemachineModule.h.filename, flow.statemachineHeaderHContents(entry))
		}

	}

	def statemachineHeaderHContents(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «statemachineModule.define»_H_
		#define «statemachineModule.define»_H_
		
		#define FUSION_MAX_VECTOR_SIZE      10
		#define BOOST_MPL_CFG_NO_PREPROCESSED_HEADERS
		#define BOOST_MPL_LIMIT_VECTOR_SIZE 10
		#define BOOST_MPL_LIMIT_MAP_SIZE 10
		
		#include <boost/msm/back/state_machine.hpp>
		#include <boost/msm/front/state_machine_def.hpp>
		#include <boost/msm/front/functor_row.hpp>
		
		#include "«statesModule.h.filename»"
		«FOR Scope it : scopes»		
			#include "«eventsModule.filename.h»"
		«ENDFOR»
		#include "«statemachineInterfaceModule.h.filename»"
		
		namespace «entry.cppNamespace» {
		
		class «statemachineLogic»: public boost::msm::front::state_machine_def<«statemachineLogic»> {
		private:
		
			«FOR InterfaceScope it : interfaces»
			«handlerInterfaceTypeName»* «handlerInterfaceMemberName»;
			«ENDFOR»
		public:
			«statemachineLogic»(«handlerInterfaceTypes»);
			virtual ~«statemachineLogic»();
		
			typedef int no_exception_thrown;
		
			typedef boost::mpl::vector<«enterStatesList»> initial_state;
		
		«transitionTable»

			// Replaces the default no-transition response.
			template<class FSM, class Event>
			void no_transition(Event const& event, FSM&, int nState) {
				std::cout << "no transition for event " << debug::debug_type<Event>()
						<< " in statemachine " << debug::debug_type<FSM>() << std::endl;
			}
		};
			
			// Pick a back-end
		class «statemachineBackend» : public boost::msm::back::state_machine<«statemachineLogic»>, public «statemachineInterfaceName»
		{
		public:
			«statemachineBackend»(«handlerInterfaceTypes»);
			virtual ~«statemachineBackend»();

			«FOR InterfaceScope it : interfaces»
				«eventVirtualMethods»
			«ENDFOR»
			
			virtual void enter();
		};
			
	} /* namespace «entry.cppNamespace» */
			
	#endif /* «statemachineInterfaceModule.define»_H_ */
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
	
	def transitionTable(ExecutionFlow it) {
		
		var table = it.transitions
		'''
		private:
			«FOR it: table»
				«action?.declaration(event)»
			«ENDFOR»
		public:
			// Transition table
			struct transition_table: boost::mpl::vector<
			«FOR it: table SEPARATOR ","»
				«row»<«sourceState.stateTypeQualifiedName», «event.eventTypeQualifiedName», «targetState.stateTypeQualifiedName» «action?.row»>
			«ENDFOR»
			> {};
		'''
	}
	
	def hasAction(Transitions.TransitionTableEntry it) {
		action != null
	} 
	
	def row(Transitions.TransitionTableEntry it) '''
		«IF hasAction»a_row«ELSE»_row«ENDIF»'''
	
	def CharSequence row(OperationDefinition it) {
		", &" + it.flow.statemachineLogic + "::" + it.asFunction
	}
	
	def declaration(OperationDefinition it, EventDefinition event) '''
		virtual void «asFunction»(const «event.eventTypeQualifiedName»&);
	'''
	
}
