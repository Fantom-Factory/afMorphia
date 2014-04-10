using afIoc

internal class TestDocumentConverter : MorphiaTest {
	
	Void testNullStrategy_nullProperty() {
		docConverter := (Converter) reg.createProxy(Converter#, DocumentConverter#, [true])
		mongoObj := (Str:Obj?) docConverter.toMongo(T_Entity05())
		verify(mongoObj.containsKey("empty"))
		verifyNull(mongoObj.getOrThrow("empty"))
	}

	Void testNullStrategy_noProperty() {
		docConverter := (Converter) reg.createProxy(Converter#, DocumentConverter#, [false])
		mongoObj := (Str:Obj?) docConverter.toMongo(T_Entity05())
		verifyFalse(mongoObj.containsKey("empty"))
	}
}

internal class T_Entity05 {
	@Property Str? empty
}
