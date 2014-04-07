
internal class TestSerializeEmbedded : MorphiaTest {
	
	Serializer? serializer
	
	override Void setup() {
		serializer = Serializer() { }
	}

	Void testSerializeEmbedded() {
		ent := T_Entity02()

		doc := serializer.toMongoDoc(ent)
		
		map := (Str:Obj?) doc["name"]
		verifyEq(map["name"], "Dredd")
		verifyEq(map["badge"], 69)
	}

	Void testDeserializeEmbedded() {
		doc := ["name":["name":"Dredd", "badge":69]]

		ent := (T_Entity02) serializer.fromMongoDoc(doc, T_Entity02#)
		
		verifyEq(ent.name.name, "Dredd")
		verifyEq(ent.name.badge, 69)
	}

}

internal class T_Entity02 {
	@Property
	T_Entity_Name1	name	:= T_Entity_Name1()

	new make(|This|? in := null) { in?.call(this) }
}

internal class T_Entity_Name1 {
	@Property Str name	:= "Dredd"
	@Property Int badge	:= 69
	
	new make(|This|? in := null) { in?.call(this) }
}
