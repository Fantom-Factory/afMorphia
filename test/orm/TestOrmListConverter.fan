
internal class TestOrmBsonListConverter : Test {
	
	Void testToBson() {
		ent := T_Entity12() { list = [T_Entity08_Enum.wot, T_Entity08_Enum.ever] }
		doc := BsonConverters().toBsonDoc(ent)
		map := (Obj[]) doc["list"]

		verifyEq(map[0], "wot")
		verifyEq(map[1], "ever")
	}

	Void testFromBson() {
		doc := ["list":["wot", "ever"]]
		ent := (T_Entity12) BsonConverters().fromBsonDoc(doc, T_Entity12#)

		verifyEq(ent.list.of, T_Entity08_Enum#)
		verifyEq(ent.list[0], T_Entity08_Enum.wot )
		verifyEq(ent.list[1], T_Entity08_Enum.ever)
	}

	Void testFromBsonNullItems() {
		// it tests this stoopid Fantom bug - [Nullable Generic Lists]`https://fantom.org/forum/topic/2777`
		doc := ["list":["wot", null, "ever"]]
		ent := (T_Entity03) BsonConverters().fromBsonDoc(doc, T_Entity03#)

		verifyEq(ent.list.of, T_Entity08_Enum?#)
		verifyEq(ent.list[0], T_Entity08_Enum.wot )
		verifyEq(ent.list[1], null)
		verifyEq(ent.list[2], T_Entity08_Enum.ever)
	}

	Void testNullStrategy() {
		obj := BsonConverters().fromBsonVal(null, Int?[]?#)
		verifyNull(obj)
	}
}

internal class T_Entity12 {
	@BsonProperty T_Entity08_Enum[]? list
	new make(|This|? in := null) { in?.call(this) }
}

internal class T_Entity03 {
	@BsonProperty T_Entity08_Enum?[]? list
	new make(|This|? in := null) { in?.call(this) }
}
