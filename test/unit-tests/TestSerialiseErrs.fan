using afIoc

internal class TestSerialiseErrs: MorphiaTest {
	
	@Inject Morphia? serialiser

	Void testPropertyNotFound() {
		verifyMorphiaErrMsg(Msgs.document_propertyNotFound(T_Entity02#name, ["wot":"ever"])) {
			serialiser.fromMongoDoc(T_Entity02#, ["wot":"ever"])
		}
	}

	Void testPropertyIsNull() {
		verifyMorphiaErrMsg(Msgs.document_propertyIsNull("name", T_Entity02#name, ["name":null])) {
			serialiser.fromMongoDoc(T_Entity02#, ["name":null])
		}
	}

	Void testPropertyDoesNotFit_embedded() {
		verifyMorphiaErrMsg(Msgs.document_propertyDoesNotFitField("int", Float#, T_Entity03#int, ["int":69f])) {
			serialiser.fromMongoDoc(T_Entity03#, ["int":69f])
		}
	}
	
	Void testTypeNotMapped() {
		verifyMorphiaErrMsg(Msgs.document_noConverter(MorphiaTest#, "wotever")) {
			mongoDoc := [ "oops" : "wotever" ]		
			serialiser.fromMongoDoc(T_Entity04#, mongoDoc)
		}
	}

}

internal class T_Entity03 {
	@Property Int int := 3
}

internal class T_Entity04 {
	@Property MorphiaTest oops
	new make(|This|in) { in(this) }
}
