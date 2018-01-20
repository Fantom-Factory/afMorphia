
internal class TestListConverter : MorphiaTest {
	
	Void testNullStrategy_null() {
		listConverter := (Converter) scope.build(ListConverter#)
		fanObj := listConverter.toFantom(Int?[]?#, null)
		verifyNull(fanObj)
	}

	// this test is wrong - if null is stored in Mongo, then null is what we get!
//	Void testNullStrategy_emptyList() {
//		listConverter := (Converter) reg.createProxy(Converter#, ListConverter#)
//		fanObj := listConverter.toFantom(Int?[]#, null)
//		
//		verifyNotNull(fanObj)
//		verifyType(fanObj, Int?[]#)
//		
//		// ensure we don't waste resources allocating space for a list we're (very) unlikely to add anything to
//		fanList := (Int?[]) fanObj
//		verifyEq(fanList.capacity, 0)
//	}
	
	Void testValSame() {
		listConverter := (Converter) scope.build(ListConverter#)

		monList	:= Obj?["gold","welsh"]
		fanList	:= listConverter.toFantom(Obj?[]#, monList) as Obj?[]
		
		verifySame(fanList, monList)
		verifyEq(fanList[0], "gold")
		verifyEq(fanList[1], "welsh")
	}
	
	Void testValCopy() {
		listConverter := (Converter) scope.build(ListConverter#)

		monList	:= Obj?["gold","welsh"]
		fanList	:= listConverter.toFantom(Str[]#, monList) as Str[]
		
		// todo: we can't test they've not been converted unless we override a dodgy Str converter
		verifyNotSame(fanList, monList)
		verifyEq(fanList[0], "gold")
		verifyEq(fanList[1], "welsh")
	}
	
	Void testValConversion() {
		listConverter := (Converter) scope.build(ListConverter#)

		monList	:= Obj?["wot","ever"]
		fanList	:= listConverter.toFantom(T_Entity01_Enum[]#, monList) as T_Entity01_Enum[]
		
		verifyNotSame(fanList, monList)
		verifyEq(fanList[0], T_Entity01_Enum.wot)
		verifyEq(fanList[1], T_Entity01_Enum.ever)
	}
}
