using afIoc

internal class TestSerialiseEmbedded : MorphiaTest {
	
	@Inject Serialiser? serialiser
	
	Void testSerializeEmbedded() {
		ent := T_Entity02()

		doc := serialiser.toMongoDoc(ent)
		
		map := (Str:Obj?) doc["name"]
		verifyEq(map["name"], "Dredd")
		verifyEq(map["badge"], 69)
	}

	Void testDeserializeEmbedded() {
		doc := ["name":["name":"Dredd", "badge":69]]

		ent := (T_Entity02) serialiser.fromMongoDoc(T_Entity02#, doc)
		
		verifyEq(ent.name.name, "Dredd")
		verifyEq(ent.name.badge, 69)
	}

//	Void testSerializeViaStaticCtor() {
//		ent := T_Entity04() {
//			name = T_Entity04_Name() { it.name="micky"; it.badge=2 }
//		}
//
//		doc := serializer.toMongoDoc(ent)
//		
//		map := (Str) doc["name"]
//		verifyEq(map, "micky:2")
//	}
//
//	Void testDeserializeViaStaticCtor() {
//		doc := ["name":"Dredd:69"]
//
//		ent := (T_Entity04) serializer.fromMongoDoc(T_Entity04#, doc)
//		
//		verifyEq(ent.name.name, "Dredd")
//		verifyEq(ent.name.badge, 69)
//	}
//
//	Void testSerializeViaCtor() {
//		ent := T_Entity05() {
//			name = T_Entity05_Name() { it.name="mouse"; it.badge=4 }
//		}
//
//		doc := serializer.toMongoDoc(ent)
//		
//		map := (Str) doc["name"]
//		verifyEq(map, "mouse:4")
//	}
//
//	Void testDeserializeViaCtor() {
//		doc := ["name":"Dredd:690"]
//
//		ent := (T_Entity05) serializer.fromMongoDoc(T_Entity05#, doc)
//		
//		verifyEq(ent.name.name, "Dredd")
//		verifyEq(ent.name.badge, 690)
//	}

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

internal class T_Entity04 {
	@Property T_Entity04_Name name
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity04_Name {
	@Property Str name
	@Property Int badge
	new make(|This|? in := null) { in?.call(this) }
	
	static new fromMongo(Str property) {
		T_Entity04_Name {
			it.name  = property.split(':')[0]
			it.badge = property.split(':')[1].toInt
		}
	}
	static Str toMongo(T_Entity04_Name name) {
		"${name.name}:${name.badge}"
	}
}

internal class T_Entity05 {
	@Property T_Entity05_Name name
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity05_Name {
	@Property Str name
	@Property Int badge
	new make(|This|? in := null) { in?.call(this) }
	
	new makeFromMongo(Str property) {
		this.name  = property.split(':')[0]
		this.badge = property.split(':')[1].toInt
	}
	Str toMongo() {
		"${name}:${badge}"
	}
}
