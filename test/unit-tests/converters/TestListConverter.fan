using afIoc

internal class TestListConverter : MorphiaTest {
	
	Void testNullStrategy_null() {
		listConverter := (Converter) reg.createProxy(Converter#, ListConverter#, [false])
		fanObj := listConverter.toFantom(Int?[]#, null)
		verifyNull(fanObj)
	}

	Void testNullStrategy_emptyList() {
		listConverter := (Converter) reg.createProxy(Converter#, ListConverter#, [true])
		fanObj := listConverter.toFantom(Int?[]#, null)
		
		verifyNotNull(fanObj)
		verifyType(fanObj, Int?[]#)
		
		// ensure we don't waste resources allocating space for a list we're (very) unlikely to add anything to
		fanList := (Int?[]) fanObj
		verifyEq(fanList.capacity, 0)
	}
}
