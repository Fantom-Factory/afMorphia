using afIoc::Inject

internal class TestSerialiseEmbedded : MorphiaTest {
	
	@Inject Converters? serialiser
	
	Void testSerializeEmbedded() {
		ent := T_Entity02()

		doc := serialiser.toMongo(T_Entity02#, ent) as Map
		
		map := (Str:Obj?) doc["name"]
		verifyEq(map["name"], "Dredd")
		verifyEq(map["badge"], 69)
	}

	Void testDeserializeEmbedded() {
		doc := ["name":["name":"Dredd", "badge":69]]

		ent := (T_Entity02) serialiser.toFantom(T_Entity02#, doc)
		
		verifyEq(ent.name.name, "Dredd")
		verifyEq(ent.name.badge, 69)
	}
}

internal class T_Entity02 {
	@Property T_Entity02_Name name	:= T_Entity02_Name()
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity02_Name {
	@Property Str name	:= "Dredd"
	@Property Int badge	:= 69
	new make(|This|? in := null) { in?.call(this) }
}
