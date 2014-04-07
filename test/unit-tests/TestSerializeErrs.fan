using afIoc

internal class TestSerializeErrs: MorphiaTest {
	
	@Inject Serializer? serializer

	Void testPropertyNotFound() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyNotFound(T_Entity02#name, ["wot":"ever"])) {
			serializer.fromMongoDoc(["wot":"ever"], T_Entity02#)
		}
	}

	Void testPropertyIsNull_literal() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyIsNull("int", T_Entity03#int, ["int":null])) {
			serializer.fromMongoDoc(["int":null], T_Entity03#)
		}
	}

	Void testPropertyIsNull_embedded() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyIsNull("name", T_Entity02#name, ["name":null])) {
			serializer.fromMongoDoc(["name":null], T_Entity02#)
		}
	}

	Void testPropertyDoesNotFit_embedded() {
		verifyMorphiaErrMsg(Msgs.serializer_propertyDoesNotFitField("int", Float#, T_Entity03#int, ["int":69f])) {
			serializer.fromMongoDoc(["int":69f], T_Entity03#)
		}
	}

}

internal class T_Entity03 {
	@Property Int int := 3
}