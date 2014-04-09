using afIoc

internal class TestSerialiseList : MorphiaTest {
	
	@Inject Serialiser? serialiser

	Void testSerializeListVals() {
		ent := T_Entity07() {
			list = [T_Entity06_Enum.wot, T_Entity06_Enum.ever]
		}

		doc := serialiser.toMongoDoc(ent)
		Env.cur.err.printLine(doc)
		map := (Obj[]) doc["list"]
		verifyEq(map[0], "wot")
		verifyEq(map[1], "ever")
	}
	
	Void testDeserializeListVals() {
		doc := ["list":["wot", "ever"]]

		ent := (T_Entity07) serialiser.fromMongoDoc(T_Entity07#, doc)
		
		verifyEq(ent.list[0], T_Entity06_Enum.wot )
		verifyEq(ent.list[1], T_Entity06_Enum.ever)
	}
}

internal class T_Entity07 {
	@Property T_Entity06_Enum[]? list
	new make(|This|? in := null) { in?.call(this) }
}
