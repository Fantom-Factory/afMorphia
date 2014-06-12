using afIoc

internal class TestMapConverter : MorphiaTest {
	
	Void testNullStrategy_null() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)
		fanObj := mapConverter.toFantom([Int:Str?]?#, null)
		verifyNull(fanObj)
	}

//	Void testNullStrategy_emptyList() {
//		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)
//		fanObj := mapConverter.toFantom([Int:Str?]#, null)
//		
//		verifyNotNull(fanObj)
//		verifyType(fanObj, [Int:Str?]#)
//		
//		fanMap := ([Int:Str?]) fanObj
//		verifyEq(fanMap.size, 0)
//	}
	
	Void testKeySameValSame() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)

		monMap	:= Str:Obj?["gold":42]
		fanMap	:= mapConverter.toFantom([Str:Obj?]#, monMap) as [Str:Obj?]
		
		verifySame(fanMap, monMap)
		verifyEq(fanMap["gold"], 42)
	}
	
	Void testKeySameValCopy() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)

		monMap	:= Str:Int["gold":42]
		fanMap	:= mapConverter.toFantom([Str:Int]#, monMap) as [Str:Int]
		
		verifySame(fanMap, monMap)
		verifyEq(fanMap["gold"], 42)
	}
	
	Void testKeySameValConvert() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)

		monMap	:= Str:Obj["gold":"ever"]
		fanMap	:= mapConverter.toFantom([Str:T_Entity01_Enum]#, monMap) as [Str:T_Entity01_Enum]
		
		verifyNotSame(fanMap, monMap)
		verifyEq(fanMap["gold"], T_Entity01_Enum.ever)
	}
	
	Void testKeyConvertValConvert() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)
		
		monMap	:= Str:Obj?["wot":"ever", "ever":"wot"]
		fanMap	:= mapConverter.toFantom([T_Entity01_Enum:T_Entity01_Enum?]#, monMap) as [T_Entity01_Enum:T_Entity01_Enum?]

		verifyNotSame(fanMap, monMap)
		verifyEq(fanMap[T_Entity01_Enum.wot], T_Entity01_Enum.ever)
		verifyEq(fanMap[T_Entity01_Enum.ever], T_Entity01_Enum.wot)		
	}

	Void testKeyConvertErr() {
		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)
		
		fanMap	:= [Err():"wotever"]
		verifyErrMsg(MorphiaErr#, ErrMsgs.mapConverter_cannotCoerceKey(Err#)) {
			mapConverter.toMongo(fanMap)
		}
	}
}
