using afIoc

internal class TestSerialiseErrs: MorphiaTest {
	
	@Inject Converters? serialiser

	Void testPropertyNotFound() {
		verifyMorphiaErrMsg(ErrMsgs.documentConv_propertyNotFound(T_Entity02#name, ["wot":"ever"])) {
			serialiser.toFantom(T_Entity02#, ["wot":"ever"])
		}
	}

	Void testPropertyIsNull() {
		verifyMorphiaErrMsg(ErrMsgs.documentConv_propertyIsNull("name", T_Entity02#name, ["name":null])) {
			serialiser.toFantom(T_Entity02#, ["name":null])
		}
	}

	Void testPropertyDoesNotFit_embedded() {
		verifyMorphiaErrMsg(ErrMsgs.documentConv_propertyDoesNotFitField("int", Float#, T_Entity03#int, ["int":69f])) {
			serialiser.toFantom(T_Entity03#, ["int":69f])
		}
	}
	
	Void testTypeNotMapped() {
		verifyMorphiaErrMsg(ErrMsgs.documentConv_noConverter(MorphiaTest#, "wotever")) {
			mongoDoc := [ "oops" : "wotever" ]		
			serialiser.toFantom(T_Entity04#, mongoDoc)
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
