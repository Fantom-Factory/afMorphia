
internal class TestOrmPropertyName : Test {
	
	Void testFromBson() {
		bsonObj := [
			"judge"	: "dude"
		]
		
		entity := (T_Entity09) BsonConverters().fromBsonDoc(bsonObj, T_Entity09#)
		
		verifyEq(entity.wotever, 	"dude")
	}
	
	Void testToBson() {
		entity := T_Entity09() {
			wotever		= "dude"
		}
		
		bsonObj := BsonConverters().toBsonDoc(entity)
		
		verifyEq(bsonObj["judge"],		"dude")
	}
}

internal class T_Entity09 {
	@BsonProperty { name="judge" }
			Str			wotever

	new make(|This|in) { in(this) }
}
