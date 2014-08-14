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
import org.yakindu.sct.model.sexec.ExecutionRegion
import org.yakindu.sct.model.sgen.GeneratorEntry
import org.yakindu.sct.model.sgraph.Statechart

class States {
	@Inject extension Naming
	@Inject extension GenmodelEntries
	@Inject extension FlowCode

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
		#define «statesModule.define»_H_
		
		#include "«baseStateModule.h.filename»"
		
		namespace «entry.cppNamespace» {
			
		«FOR ExecutionRegion it : regions»
			«stateTypes»
		«ENDFOR»
		
		} /* namespace «entry.cppNamespace» */
		
		#endif /* «statesModule.define»_H_ */
	'''

}
