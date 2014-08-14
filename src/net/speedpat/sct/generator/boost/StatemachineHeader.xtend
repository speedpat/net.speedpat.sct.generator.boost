/**
 * Copyright (c) 2014 Patrick Heeb.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.stext.stext.InterfaceScope

class StatemachineHeader {
	@Inject extension Naming
	@Inject extension GenmodelEntries
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
				«transition»
			«ENDFOR»
			> {};
		'''
	}

	
}
