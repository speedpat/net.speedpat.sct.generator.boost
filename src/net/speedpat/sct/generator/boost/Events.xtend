package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Event
import org.yakindu.sct.model.sgraph.Scope
import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.stext.stext.EventDefinition

class Events {

	@Inject extension Naming
	@Inject extension GenmodelEntries

	def generateEventsHpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {
		for (Scope scope : flow.scopes) {
			scope.generateEventsHpp(flow, fsa, entry)
		}

	}

	def void generateEventsHpp(Scope scope, ExecutionFlow flow, IFileSystemAccess fsa, GeneratorEntry entry) {
		if (fsa instanceof SimpleResourceFileSystemAccess) {
			fsa.generateFile(scope.eventsModule.h.filename, scope.eventsHContent(flow, entry))
		}
	}

	def eventsHContent(Scope it, ExecutionFlow flow, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «eventsModule.define»_H_
		#define «eventsModule.define»_H_
		
		#include "«flow.typesModule.h.filename»"
		
		namespace «entry.cppNamespace» {
		
		«FOR Event it : events»
			«eventType»
		«ENDFOR»
		
		} /* namespace «entry.cppNamespace» */
		
		#endif /* «eventsModule.define»_H_ */
	'''

	def eventType(Event it) {
		switch (it) {
			EventDefinition: it.eventType
		}
	}

	def eventType(EventDefinition it) {
		'''
		struct «name» {
			«eventValueParams»
		};
		'''
	}
}
