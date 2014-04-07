
abstract internal class MorphiaTest : Test {

	Void verifyMorphiaErrMsg(Str errMsg, |Obj| func) {
		verifyErrMsg(MorphiaErr#, errMsg, func)
	}

	protected Void verifyErrMsg(Type errType, Str errMsg, |Obj| func) {
		try {
			func(4)
		} catch (Err e) {
			if (!e.typeof.fits(errType)) 
				throw Err("Expected $errType got $e.typeof", e)
			verifyEq(errMsg, e.msg)	// this gives the Str comparator in eclipse
			return
		}
		throw Err("$errType not thrown")
	}
}
