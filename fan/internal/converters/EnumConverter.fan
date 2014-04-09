
internal const class EnumConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		type.method("fromStr").call(mongoObj, true)
	}
	
	override Obj? toMongo(Type type, Obj? fantomObj) {
		((Enum?) fantomObj)?.name
	}

}
