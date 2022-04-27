
internal class TestOrmPropertyName : Test {
	
	Void testFromBson() {
		bsonObj := [
			"judge"	: "dude"
		]
		
		entity := (T_Entity09) BsonConvs().fromBsonDoc(bsonObj, T_Entity09#)
		
		verifyEq(entity.wotever, 	"dude")
	}
	
	Void testToBson() {
		entity := T_Entity09() {
			wotever		= "dude"
		}
		
		bsonObj := BsonConvs().toBsonDoc(entity)
		
		verifyEq(bsonObj["judge"],		"dude")
	}
}

internal class T_Entity09 {
	@BsonProp { name="judge" }
			Str			wotever

	new make(|This|in) { in(this) }
}
