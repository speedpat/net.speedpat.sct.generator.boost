package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Statechart

class Types {

	@Inject extension Naming
	@Inject extension GenmodelEntries

	def generateTypesHpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {

		if (fsa instanceof SimpleResourceFileSystemAccess) {

			if (!exists(flow.typesModule.h, fsa as SimpleResourceFileSystemAccess)) {
				fsa.generateFile(flow.typesModule.h.filename, flow.typesHContent(entry))
			}

			if (!exists(flow.baseStateModule.h, fsa as SimpleResourceFileSystemAccess)) {
				fsa.generateFile(flow.baseStateModule.h.filename, flow.baseStateHContent(entry))
			}

			if (!exists(flow.debugTypeModule.h, fsa as SimpleResourceFileSystemAccess)) {
				fsa.generateFile(flow.debugTypeModule.h.filename, flow.debugTypeHContent(entry))
			}
		}
	}

	def protected exists(String filename, SimpleResourceFileSystemAccess fsa) {
		val uri = fsa.getURI(filename);
		val file = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(uri.toPlatformString(true)));
		return file.exists;
	}

	def debugTypeHContent(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «debugTypeModule.define»_H_
		#define «debugTypeModule.define»_H_
		
		namespace debug
		{
			template <typename Type>
			std::string debug_type() {
			   	char * name = 0;
			   	std::string eventName;
			   	int status;
				name = abi::__cxa_demangle(typeid(Type).name(), 0, 0, &status);
				if (name != 0)
				{
					eventName = name;
				}
				else
				{
					eventName = typeid(Type).name();
				}
				free(name);
				return eventName;
			}
		}
		
		#endif /* «debugTypeModule.define»_H_ */
	'''

	def baseStateHContent(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «baseStateModule.define»_H_
		#define «baseStateModule.define»_H_
		
		#include <boost/msm/front/states.hpp>
		#include "«debugTypeModule.h.filename»"
		
		namespace «entry.cppNamespace» {
		template <typename State>
		struct base_state : public boost::msm::front::state<>{
		
			template <class Event, class FSM>
			void on_entry(Event const&, FSM&)
			{
				std::cout
						<< "entering state " << debug::debug_type<State>()
						<< " from event " << debug::debug_type<Event>()
						<< " in " << debug::debug_type<FSM>()
						<< std::endl;
			}
		
			template <class Event,class FSM>
			void on_exit(Event const&, FSM&)
			{
			std::cout
					<< "exiting state " << debug::debug_type<State>()
					<< " from event " << debug::debug_type<Event>()
					<< " in " << debug::debug_type<FSM>()
					<< std::endl;
			
			}
		};
		
		} /* namespace «entry.cppNamespace» */
		
		#endif /* «baseStateModule.define»_H_ */
	'''

	def typesHContent(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «typesModule.define»_H_
		#define «typesModule.define»_H_
		
		typedef unsigned char	sc_ushort;
		typedef int				sc_integer;  
		typedef double			sc_real;
		typedef char*			sc_string;
		typedef bool			sc_boolean;
		
		typedef void*			sc_eventid;
		
		#ifndef «Naming::NULL_STRING»
			#define «Naming::NULL_STRING» 0
		#endif
		
		#endif /* «typesModule.define»_H_ */
	'''
}
