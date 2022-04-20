
internal class TestOrmObjConversion : Test {
	
	Void testConversion() {
		ent := BsonConverters().fromBsonDoc([
			"obj1"	: 68,
			"obj2"	: "judge",
			"obj3"	: 68.9f,
			"obj4"	: ["foo":"bar"],
		], T_Entity04#) as T_Entity04
		verifyEq(ent.obj1, 68)
		verifyEq(ent.obj2, "judge")
		verifyEq(ent.obj3, 68.9f)
		verifyEq(ent.obj4, Str:Str["foo":"bar"])
	}

	Void testNoConversion() {
		verifyErrMsg(Err#, "BSON property obj2 of type Str does not fit field afMorphia::T_Entity02.obj2 of type Buf? : [obj1:68, obj2:judge]") {
			BsonConverters().fromBsonDoc([:]{ordered=true}.add("obj1",68).add("obj2","judge"), T_Entity02#)
		}
	}
}

internal class T_Entity04 {
	@BsonProperty	Obj? obj1
	@BsonProperty	Obj? obj2
	@BsonProperty	Obj? obj3
	@BsonProperty	Obj? obj4

	// T_Entity04 also tests that entities can be created *without* an it-block ctor - which requires afBeanUtils::BeanBuilder
}

internal class T_Entity02 {
	@BsonProperty	Obj? obj1
	@BsonProperty	Buf? obj2
}
