package net.speedpat.sct.generator.boost

import com.google.inject.Inject
import org.yakindu.sct.generator.cpp.ExpressionCode
import org.yakindu.sct.generator.cpp.Navigation
import org.yakindu.sct.model.sexec.Call
import org.yakindu.sct.model.sexec.EnterState
import org.yakindu.sct.model.sexec.ExitState
import org.yakindu.sct.model.sexec.Sequence
import org.yakindu.sct.model.sexec.naming.INamingService

class FlowCode extends org.yakindu.sct.generator.cpp.FlowCode {

	@Inject extension Naming
	@Inject extension Navigation
	@Inject extension ExpressionCode
	@Inject extension INamingService
	
	override dispatch CharSequence code(Call it) 
		'''«step.shortName»();'''
	
	override dispatch CharSequence code(Sequence it) '''
		/* «it.class.name» */
		«IF !steps.nullOrEmpty»«stepComment»«ENDIF»
		«FOR s : steps»
			«s.code»
		«ENDFOR»
	'''	
	
	override dispatch CharSequence code(EnterState it) '''
		«state.shortName»;
	'''
	
	override def dispatch CharSequence code(ExitState it) '''
		«state.shortName»;
	'''

}
