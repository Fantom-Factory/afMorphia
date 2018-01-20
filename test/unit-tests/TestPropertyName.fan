using afIoc::Inject

internal class TestPropertyName : MorphiaTest {
	
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
		
		mongoDoc := serialiser.toMongo(T_Entity08#, entity) as Map
		
		verifyEq(mongoDoc["judge"],		"dude")
	}
}

internal class T_Entity08 {
	@Property { name="judge" }	Str	wotever
	new make(|This|in) { in(this) }
}
