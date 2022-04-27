
internal class TestOrmPropertyType : Test {
	
	Void testFromBson() {
		bsonObj := [ "intx"	: 42f ]
		entity  := (T_Entity10) BsonConvs().fromBsonDoc(bsonObj, T_Entity10#)
		verifyEq(entity.intx, 	42f)

		bsonObj = [ "inty"	: 42f ]
		verifyErrMsg(Err#, "BSON property inty of type Float does not fit field afMorphia::T_Entity10.inty of type Num? : [inty:42.0]") {
			BsonConvs().fromBsonDoc(bsonObj, T_Entity10#)
		}
	}
	
	Void testToBson() {
		entity := T_Entity10() {
			inty	= 42
		}
		
		bsonObj := BsonConvs().toBsonDoc(entity)
		
		verifyEq(bsonObj["inty"],	42)
	}
}

internal class T_Entity10 {
	@BsonProp
			Num?		intx
	@BsonProp { implType=Int?# }
			Num?		inty

	new make(|This|in) { in(this) }
}
