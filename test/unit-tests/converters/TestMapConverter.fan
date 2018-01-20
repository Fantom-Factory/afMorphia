
internal class TestMapConverter : MorphiaTest {
	
	Void testNullStrategy_null() {
		mapConverter := (Converter) scope.build(MapConverter#)
		fanObj := mapConverter.toFantom([Int:Str?]?#, null)
		verifyNull(fanObj)
	}

	// this test is wrong - if null is stored in Mongo, then null is what we get!
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
	
	// with key escaping - the map gets re-created
//	Void testKeySameValSame() {
//		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)
//
//		monMap	:= Str:Obj?["gold":42]
//		fanMap	:= mapConverter.toFantom([Str:Obj?]#, monMap) as [Str:Obj?]
//		
//		verifySame(fanMap, monMap)
//		verifyEq(fanMap["gold"], 42)
//	}
	
	// with key escaping - the map gets re-created
//	Void testKeySameValCopy() {
//		mapConverter := (Converter) reg.createProxy(Converter#, MapConverter#)
//
//		monMap	:= Str:Int["gold":42]
//		fanMap	:= mapConverter.toFantom([Str:Int]#, monMap) as [Str:Int]
//		
//		verifySame(fanMap, monMap)
//		verifyEq(fanMap["gold"], 42)
//	}
	
	Void testKeySameValConvert() {
		mapConverter := (Converter) scope.build(MapConverter#)

		monMap	:= Str:Obj["gold":"ever"]
		fanMap	:= mapConverter.toFantom([Str:T_Entity01_Enum]#, monMap) as [Str:T_Entity01_Enum]
		
		verifyNotSame(fanMap, monMap)
		verifyEq(fanMap["gold"], T_Entity01_Enum.ever)
	}
	
	Void testKeyConvertValConvert() {
		mapConverter := (Converter) scope.build(MapConverter#)
		
		monMap	:= Str:Obj?["wot":"ever", "ever":"wot"]
		fanMap	:= mapConverter.toFantom([T_Entity01_Enum:T_Entity01_Enum?]#, monMap) as [T_Entity01_Enum:T_Entity01_Enum?]

		verifyNotSame(fanMap, monMap)
		verifyEq(fanMap[T_Entity01_Enum.wot], T_Entity01_Enum.ever)
		verifyEq(fanMap[T_Entity01_Enum.ever], T_Entity01_Enum.wot)		
	}

	Void testKeyConvertErr() {
		mapConverter := (Converter) scope.build(MapConverter#)
		
		fanMap	:= [Err():"wotever"]
		verifyErrMsg(MorphiaErr#, ErrMsgs.mapConverter_cannotCoerceKey(Err#)) {
			mapConverter.toMongo(Obj#, fanMap)
		}
	}
	
	Void testUnicodeKeyEscaping() {
		key := ""

		key = MapConverter.encodeKey("xxx\\1234xxx")
		verifyEq(key, "xxx\\1234xxx")

		key = MapConverter.encodeKey("xxx\\u1234xxx")
		verifyEq(key, "xxx\\uu1234xxx")

		key = MapConverter.encodeKey("xxx\\u1a2Bxxx")
		verifyEq(key, "xxx\\uu1a2Bxxx")

		key = MapConverter.encodeKey("xxx\\uu1234xxx")
		verifyEq(key, "xxx\\uuu1234xxx")

		key = MapConverter.encodeKey("xxx\\uu1234xxx\\uu1234xxx")
		verifyEq(key, "xxx\\uuu1234xxx\\uuu1234xxx")

		key = MapConverter.encodeKey("pod.name\\pod.\$name")
		verifyEq(key, "pod\\u002ename\\pod\\u002e\\u0024name")

		key = MapConverter.encodeKey("xxx\\u123xxx")
		verifyEq(key, "xxx\\u123xxx")
	}

	Void testUnicodeKeyDescaping() {
		key := ""

		key = MapConverter.decodeKey("xxx\\1234xxx")
		verifyEq(key, "xxx\\1234xxx")

		key = MapConverter.decodeKey("xxx\\uu1234xxx")
		verifyEq(key, "xxx\\u1234xxx")

		key = MapConverter.decodeKey("xxx\\uu1a2Bxxx")
		verifyEq(key, "xxx\\u1a2Bxxx")

		key = MapConverter.decodeKey("xxx\\uuu1234xxx")
		verifyEq(key, "xxx\\uu1234xxx")

		key = MapConverter.decodeKey("xxx\\uuu1234xxx\\uuu1234xxx")
		verifyEq(key, "xxx\\uu1234xxx\\uu1234xxx")

		key = MapConverter.decodeKey("pod\\u002ename\\pod\\u002e\\u0024name")
		verifyEq(key, "pod.name\\pod.\$name")

		key = MapConverter.decodeKey("xxx\\u123xxx")
		verifyEq(key, "xxx\\u123xxx")
	}
}
