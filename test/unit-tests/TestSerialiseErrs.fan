using afIoc

internal class TestSerialiseErrs: MorphiaTest {
	
	@Inject Serialiser? serialiser

	Void testPropertyNotFound() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyNotFound(T_Entity02#name, ["wot":"ever"])) {
			serialiser.fromMongoDoc(T_Entity02#, ["wot":"ever"])
		}
	}

	Void testPropertyIsNull_literal() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyIsNull("int", T_Entity03#int, ["int":null])) {
			serialiser.fromMongoDoc(T_Entity03#, ["int":null])
		}
	}

	Void testPropertyIsNull_embedded() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyIsNull("name", T_Entity02#name, ["name":null])) {
			serialiser.fromMongoDoc(T_Entity02#, ["name":null])
		}
	}

	Void testPropertyDoesNotFit_embedded() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyDoesNotFitField("int", Float#, T_Entity03#int, ["int":69f])) {
			serialiser.fromMongoDoc(T_Entity03#, ["int":69f])
		}
	}

}

internal class T_Entity03 {
	@Property Int int := 3
}