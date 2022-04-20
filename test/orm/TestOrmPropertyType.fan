
internal class TestOrmPropertyType : Test {
	
	Void testFromBson() {
		bsonObj := [ "intx"	: 42f ]
		entity  := (T_Entity10) BsonConverters().fromBsonDoc(bsonObj, T_Entity10#)
		verifyEq(entity.intx, 	42f)

		bsonObj = [ "inty"	: 42f ]
		verifyErrMsg(Err#, "BSON property inty of type Float does not fit field afMorphia::T_Entity10.inty of type Num? : [inty:42.0]") {
			BsonConverters().fromBsonDoc(bsonObj, T_Entity10#)
		}
	}
	
	Void testToBson() {
		entity := T_Entity10() {
			inty	= 42
		}
		
		bsonObj := BsonConverters().toBsonDoc(entity)
		
		verifyEq(bsonObj["inty"],	42)
	}
}

internal class T_Entity10 {
	@BsonProperty
			Num?		intx
	@BsonProperty { implType=Int?# }
			Num?		inty

	new make(|This|in) { in(this) }
}
