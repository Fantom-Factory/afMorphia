
internal class TestOrmObjConverter : Test {
	
	Void testToBson() {
		ent := T_Entity11()
		obj := BsonConverters().toBsonDoc(ent)

		map := (Str:Obj?) obj["name"]
		verifyEq(map["name"], "Dredd")
		verifyEq(map["badge"], 69)
	}

	Void testFromBson() {
		obj := ["name":["name":"Dredd", "badge":69]]
		ent := (T_Entity11) BsonConverters().fromBsonDoc(obj, T_Entity11#)
		
		verifyEq(ent.name.name, "Dredd")
		verifyEq(ent.name.badge, 69)
	}

	Void testStrictMode() {
		obj := ["name":["name":"Dredd", "badge":69, "ammo":"hi-ex"]]
		verifyErrMsg(Err#, "Extraneous data in BSON object for afMorphia::T_Entity11_Name: ammo") {
			BsonConverters(null, ["strictMode":true]).fromBsonDoc(obj, T_Entity11#)
		}
	}
	
	Void testDynamicType() {
		ent := T_Entity05 {
			it.impl1 = T_Entity06_Impl1()
			it.impl2 = T_Entity06_Impl2()
		}
		obj := BsonConverters().toBsonDoc(ent)
		
		rebirth := (T_Entity05) BsonConverters().fromBsonDoc(obj, T_Entity05#)
		
		verifyEq(rebirth.impl1->name, "Dredd")
		verifyEq(rebirth.impl2->name, "Death")
	}
	
	Void testNullStrategy_nullProperty() {
		docConv  := BsonConverters(null, ["storeNullFields":true])
		mongoObj := docConv.toBsonDoc(T_Entity14())
		verify    (mongoObj.containsKey("empty"))
		verifyNull(mongoObj.getOrThrow("empty"))
	}

	Void testNullStrategy_noProperty() {
		docConv  := BsonConverters(null, ["storeNullFields":false])
		mongoObj := docConv.toBsonDoc(T_Entity14())
		verifyFalse(mongoObj.containsKey("empty"))
	}
}

internal class T_Entity11 {
	@BsonProperty T_Entity11_Name name	:= T_Entity11_Name()
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity11_Name {
	@BsonProperty Str name	:= "Dredd"
	@BsonProperty Int badge	:= 69
	new make(|This|? in := null) { in?.call(this) }
}

internal class T_Entity05 {
	@BsonProperty T_Entity06 impl1
	@BsonProperty T_Entity06 impl2
	new make(|This|? in := null) { in?.call(this) }
}
internal mixin T_Entity06 { }
internal class T_Entity06_Impl1 : T_Entity06 {
	@BsonProperty Type _type	:= typeof
	@BsonProperty Str	name	:= "Dredd"
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity06_Impl2 : T_Entity06 {
	@BsonProperty Type _type	:= typeof
	@BsonProperty Str	name	:= "Death"
	new make(|This|? in := null) { in?.call(this) }
}

internal class T_Entity14 {
	@BsonProperty Str? empty
}

