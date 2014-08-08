package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.impl.SimpleResourceFileSystemAccess
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Statechart
import org.yakindu.sct.model.sexec.ExecutionState

class States {
	@Inject extension Naming
	@Inject extension GenmodelEntries

	def generateStatesHpp(ExecutionFlow flow, Statechart sc, IFileSystemAccess fsa, GeneratorEntry entry) {
		flow.generateStatesHpp(fsa, entry)
	}

	def void generateStatesHpp(ExecutionFlow flow, IFileSystemAccess fsa, GeneratorEntry entry) {
		if (fsa instanceof SimpleResourceFileSystemAccess) {
			fsa.generateFile(flow.statesModule.h.filename, flow.statesHContent(entry))
		}
	}

	def statesHContent(ExecutionFlow it, GeneratorEntry entry) '''
		«entry.licenseText»
		
		#ifndef «statesModule.define»_H_
		#define «eventsModule.define»_H_
		
		#include "«baseStateModule.h.filename»"
		
		namespace «entry.cppNamespace» {
		
		«FOR ExecutionState it : states»
			«stateType»
		«ENDFOR»
		
		} /* namespace «entry.cppNamespace» */
		
		#endif /* «eventsModule.define»_H_ */
	'''

	def stateType(ExecutionState it) {
		'''
			struct «name.stateName» : base_state<«name.stateName»> {};
		'''
	}
}
