using afIoc

internal class TestSerialiseMap : MorphiaTest {
	
	@Inject Converters? serialiser

	Void testSerialiseMapKeys() {
		ent := T_Entity06()
		ent.keys = [:]
		ent.keys[T_Entity06_Enum.wot] = 6
		ent.keys[T_Entity06_Enum.ever] = 9

		doc := serialiser.toMongo(ent) as Map
		
		map := (Str:Obj?) doc["keys"]
		verifyEq(map["wot"],  6)
		verifyEq(map["ever"], 9)
	}
	
	Void testDeserializeMapKeys() {
		doc := ["keys":["wot":6, "ever":9]]

		ent := (T_Entity06) serialiser.toFantom(T_Entity06#, doc)
		
		verifyEq(ent.keys[T_Entity06_Enum.wot], 6)
		verifyEq(ent.keys[T_Entity06_Enum.ever], 9)
	}

	Void testSerializeMapVals() {
		ent := T_Entity06()
		ent.vals = [:]
		ent.vals[6] = T_Entity06_Enum.wot
		ent.vals[9] = T_Entity06_Enum.ever

		doc := serialiser.toMongo(ent) as Map
		
		map := (Str:Obj?) doc["vals"]
		verifyEq(map["6"], "wot")
		verifyEq(map["9"], "ever")
	}

	Void testDeserializeMapVals() {
		doc := ["vals":[6:"wot", 9:"ever"]]

		ent := (T_Entity06) serialiser.toFantom(T_Entity06#, doc)
		
		verifyEq(ent.vals[6], T_Entity06_Enum.wot)
		verifyEq(ent.vals[9], T_Entity06_Enum.ever)
	}
}

internal class T_Entity06 {
	@Property [T_Entity06_Enum:Int]? keys
	@Property [Int:T_Entity06_Enum]? vals
	new make(|This|? in := null) { in?.call(this) }
}
internal enum class T_Entity06_Enum {
	wot, ever;
}
