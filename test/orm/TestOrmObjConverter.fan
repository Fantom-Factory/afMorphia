
internal class TestOrmObjConverter : Test {
	
	Void testToBson() {
		ent := T_Entity11()
		obj := BsonConvs().toBsonDoc(ent)

		map := (Str:Obj?) obj["name"]
		verifyEq(map["name"], "Dredd")
		verifyEq(map["badge"], 69)
	}

	Void testFromBson() {
		obj := ["name":["name":"Dredd", "badge":69]]
		ent := (T_Entity11) BsonConvs().fromBsonDoc(obj, T_Entity11#)
		
		verifyEq(ent.name.name, "Dredd")
		verifyEq(ent.name.badge, 69)
	}

	Void testStrictMode() {
		obj := ["name":["name":"Dredd", "badge":69, "ammo":"hi-ex"]]
		verifyErrMsg(Err#, "Extraneous data in BSON object for afMorphia::T_Entity11_Name: ammo") {
			BsonConvs(null, ["strictMode":true]).fromBsonDoc(obj, T_Entity11#)
		}
	}
	
	Void testDynamicType() {
		ent := T_Entity05 {
			it.impl1 = T_Entity06_Impl1()
			it.impl2 = T_Entity06_Impl2()
		}
		obj := BsonConvs().toBsonDoc(ent)
		
		rebirth := (T_Entity05) BsonConvs().fromBsonDoc(obj, T_Entity05#)
		
		verifyEq(rebirth.impl1->name, "Dredd")
		verifyEq(rebirth.impl2->name, "Death")
	}
	
	Void testNullStrategy_nullProperty() {
		docConv  := BsonConvs(null, ["storeNullFields":true])
		mongoObj := docConv.toBsonDoc(T_Entity16())
		verify    (mongoObj.containsKey("empty"))
		verifyNull(mongoObj.getOrThrow("empty"))
	}

	Void testNullStrategy_noProperty() {
		docConv  := BsonConvs(null, ["storeNullFields":false])
		mongoObj := docConv.toBsonDoc(T_Entity16())
		verifyFalse(mongoObj.containsKey("empty"))
	}
	
	Void testSerializableMode() {
		convs	:= BsonConvs(null, ["serializableMode":true])
		
		// check that _type info is auto generated
		bsonObj1 := convs.toBsonDoc(T_Entity11_Name())
		verifyEq(bsonObj1["_type"], "afMorphia::T_Entity11_Name")

		// note how we don't pass in the Type
		fantObj1 := convs.fromBsonVal(bsonObj1) as T_Entity11_Name
		verifyEq(fantObj1.name, "Dredd")
		
		// check embedded objs
		bsonObj2 := convs.toBsonDoc(T_Entity11())
		verifyEq(bsonObj2["_type"], "afMorphia::T_Entity11")
		verifyEq(bsonObj2["name"]->get("_type"), "afMorphia::T_Entity11_Name")
		verifyEq(bsonObj2["name"]->get("name"), "Dredd")

		// note how we don't pass in the Type
		bsonObj2["name"]->set("name", "Death")
		fantObj2 := convs.fromBsonVal(bsonObj2) as T_Entity11
		verifyEq(fantObj2.name.name, "Death")
	}
}

internal class T_Entity11 {
	@BsonProp T_Entity11_Name name	:= T_Entity11_Name()
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity11_Name {
	@BsonProp Str name	:= "Dredd"
	@BsonProp Int badge	:= 69
	new make(|This|? in := null) { in?.call(this) }
}

internal class T_Entity05 {
	@BsonProp T_Entity06 impl1
	@BsonProp T_Entity06 impl2
	new make(|This|? in := null) { in?.call(this) }
}
internal mixin T_Entity06 { }
internal class T_Entity06_Impl1 : T_Entity06 {
	@BsonProp Type _type	:= typeof
	@BsonProp Str	name	:= "Dredd"
	new make(|This|? in := null) { in?.call(this) }
}
internal class T_Entity06_Impl2 : T_Entity06 {
	@BsonProp Type _type	:= typeof
	@BsonProp Str	name	:= "Death"
	new make(|This|? in := null) { in?.call(this) }
}

internal class T_Entity16 {
	@BsonProp Str? empty
}

