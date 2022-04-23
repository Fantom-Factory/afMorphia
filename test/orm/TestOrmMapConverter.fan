
internal class TestOrmMapConverter : Test {
	
	Void testToBson() {
		ent := T_Entity13()
		ent.vals = [:]
		ent.vals[6] = T_Entity13_Enum.wot
		ent.vals[9] = T_Entity13_Enum.ever

		rec := (Str:Obj?) BsonConvs().toBsonVal(ent, T_Entity13#)

		map := (Str:Obj?) rec["vals"]
		verifyEq(map["6"], "wot")
		verifyEq(map["9"], "ever")
	}

	Void testFromBson() {
		rec := ["vals":["6":"wot", "9":"ever"]]
		ent := (T_Entity13) BsonConvs().fromBsonDoc(rec, T_Entity13#)
		
		verifyEq(ent.vals[6], T_Entity13_Enum.wot)
		verifyEq(ent.vals[9], T_Entity13_Enum.ever)
	}
	
	Void testSerialiseMapKeys() {
		ent := T_Entity13()
		ent.keys = [:]
		ent.keys[T_Entity13_Enum.wot] = 6
		ent.keys[T_Entity13_Enum.ever] = 9

		doc := BsonConvs().toBsonDoc(ent) as Map
		
		map := (Str:Obj?) doc["keys"]
		verifyEq(map["wot"],  6)
		verifyEq(map["ever"], 9)
	}
	
	Void testDeserializeMapKeys() {
		doc := ["keys":["wot":6, "ever":9]]

		ent := (T_Entity13) BsonConvs().fromBsonDoc(doc, T_Entity13#)
		
		verifyEq(ent.keys[T_Entity13_Enum.wot], 6)
		verifyEq(ent.keys[T_Entity13_Enum.ever], 9)
	}

	Void testNullStrategy_null() {
		obj := BsonConvs().fromBsonDoc(null, [Int:Str?]?#)
		verifyNull(obj)
	}

	Void testKeyConvertErr() {
		badMap	:= [Err():"wotever"]
		verifyErrMsg(Err#, "Unsupported Map key type 'sys::Err', cannot coerce from Str#") {
			BsonConvs().toBsonVal(badMap, Map#) 
		}
	}
	
	Void testUnicodeKeyEscaping() {
		key := ""

		key = BsonMapConv.encodeKey("xxx\\1234xxx")
		verifyEq(key, "xxx\\1234xxx")

		key = BsonMapConv.encodeKey("xxx\\u1234xxx")
		verifyEq(key, "xxx\\uu1234xxx")

		key = BsonMapConv.encodeKey("xxx\\u1a2Bxxx")
		verifyEq(key, "xxx\\uu1a2Bxxx")

		key = BsonMapConv.encodeKey("xxx\\uu1234xxx")
		verifyEq(key, "xxx\\uuu1234xxx")

		key = BsonMapConv.encodeKey("xxx\\uu1234xxx\\uu1234xxx")
		verifyEq(key, "xxx\\uuu1234xxx\\uuu1234xxx")

		key = BsonMapConv.encodeKey("pod.name\\pod.\$name")
		verifyEq(key, "pod\\u002ename\\pod\\u002e\\u0024name")

		key = BsonMapConv.encodeKey("xxx\\u123xxx")
		verifyEq(key, "xxx\\u123xxx")
	}

	Void testUnicodeKeyDescaping() {
		key := ""

		key = BsonMapConv.decodeKey("xxx\\1234xxx")
		verifyEq(key, "xxx\\1234xxx")

		key = BsonMapConv.decodeKey("xxx\\uu1234xxx")
		verifyEq(key, "xxx\\u1234xxx")

		key = BsonMapConv.decodeKey("xxx\\uu1a2Bxxx")
		verifyEq(key, "xxx\\u1a2Bxxx")

		key = BsonMapConv.decodeKey("xxx\\uuu1234xxx")
		verifyEq(key, "xxx\\uu1234xxx")

		key = BsonMapConv.decodeKey("xxx\\uuu1234xxx\\uuu1234xxx")
		verifyEq(key, "xxx\\uu1234xxx\\uu1234xxx")

		key = BsonMapConv.decodeKey("pod\\u002ename\\pod\\u002e\\u0024name")
		verifyEq(key, "pod.name\\pod.\$name")

		key = BsonMapConv.decodeKey("xxx\\u123xxx")
		verifyEq(key, "xxx\\u123xxx")
	}
}

internal class T_Entity13 {
	@BsonProp [T_Entity13_Enum:Int]? keys
	@BsonProp [Int:T_Entity13_Enum]? vals
	new make(|This|? in := null) { in?.call(this) }
}

internal enum class T_Entity13_Enum {
	wot, ever;
}
