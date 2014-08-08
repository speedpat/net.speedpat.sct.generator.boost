package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sexec.naming.INamingService
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.stext.stext.InterfaceScope

class StatemachineHeader {
	@Inject extension Naming
	@Inject extension GenmodelEntries
	@Inject extension INamingService

	def generateStatemachineHeaderHpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {
		if (fsa instanceof SimpleResourceFileSystemAccess) {
			fsa.generateFile(flow.statemachineHeaderModule.h.filename, flow.statemachineHeaderHContents(entry))
		}
	}

	def statemachineHeaderHContents(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «statemachineHeaderModule.define»_H_
		#define «statemachineHeaderModule.define»_H_
		
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
			«FOR it : scopes»
				«FOR it : operations»
					virtual void «name»(«parameterList»);
				«ENDFOR»
			«ENDFOR»
		
			«FOR InterfaceScope it : interfaces»
			«handlerInterfaces» «handlerInterfaceMemberName»;
			«ENDFOR»
		public:
			«statemachineLogic»(«handlerInterfaceTypes»);
			virtual ~«statemachineLogic»();
		
			typedef int no_exception_thrown;
		
			typedef boost::mpl::vector<states::initial> initial_state;
		
			// Transition table
			struct transition_table: boost::mpl::vector<
				a_row<states::initial, events::event1, states::state1,
						&ApplicationLogic::action1>,
				a_row<states::state1, events::event2, states::state2,
						&ApplicationLogic::action2> > {
		};
		
		// Replaces the default no-transition response.
		template<class FSM, class Event>
		void no_transition(Event const& event, FSM&, int nState) {
			std::cout << "no transition for event " << debug::debug_type<Event>()
					<< " in statemachine " << debug::debug_type<FSM>() << std::endl;
		}
			};
			
			} /* namespace «entry.cppNamespace» */
			
			#endif /* «statemachineInterfaceModule.define»_H_ */
	'''

}
