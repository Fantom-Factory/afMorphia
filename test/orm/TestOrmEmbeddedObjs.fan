
internal class TestOrmEmbeddedObjs : Test {
	
	Void testSerializeEmbedded() {
		ent := T_Entity15()

		doc := BsonConverters().toBsonDoc(ent)
		
		map := (Str:Obj?) doc["name"]
		verifyEq(map["name"], "Dredd")
		verifyEq(map["badge"], 69)
	}

	Void testDeserializeEmbedded() {
		doc := ["name":["name":"Dredd", "badge":69]]

		ent := (T_Entity15) BsonConverters().fromBsonDoc(doc, T_Entity15#)
		
		verifyEq(ent.name.name, "Dredd")
		verifyEq(ent.name.badge, 69)
	}
}

internal class T_Entity15 {
	@BsonProperty T_Entity15_Name name	:= T_Entity15_Name()
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity15_Name {
	@BsonProperty Str name	:= "Dredd"
	@BsonProperty Int badge	:= 69
	new make(|This|? in := null) { in?.call(this) }
}
