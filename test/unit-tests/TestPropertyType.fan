using afIoc

internal class TestPropertyType : MorphiaTest {
	
	@Inject Converters? serialiser
	
	Void testDeserializeMongoLiterals() {
		mongoDoc := [
			"judge"		: "dude"
		]
		
		entity := (T_Entity08) serialiser.toFantom(T_Entity08#, mongoDoc)
		
		verifyEq(entity.wotever, 	"dude")
	}
	
	Void testSerializeMongoLiterals() {
		entity := T_Entity08() {
			wotever		= "dude"
		}
		
		mongoDoc := serialiser.toMongo(entity) as Map
		
		verifyEq(mongoDoc["judge"],		"dude")
	}
}

internal class T_Entity15 {
	@Property { type=Int# }	Str	wotever
	new make(|This|in) { in(this) }
}

internal class T_Entity16 {
	@Property { type=Int# }	Num	wotever
	new make(|This|in) { in(this) }
}
