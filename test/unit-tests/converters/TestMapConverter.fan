using afIoc

internal class TestMapConverter : MorphiaTest {
	
	Void testNullStrategy_null() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#, [false])
		fanObj := mapConverter.toFantom([Int:Str?]#, null)
		verifyNull(fanObj)
	}

	Void testNullStrategy_emptyList() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#, [true])
		fanObj := mapConverter.toFantom([Int:Str?]#, null)
		
		verifyNotNull(fanObj)
		verifyType(fanObj, [Int:Str?]#)
		
		fanMap := ([Int:Str?]) fanObj
		verifyEq(fanMap.size, 0)
	}
}
