
internal const class EnumConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		type.method("fromStr").call(mongoObj, true)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Enum) fantomObj).name
	}

}
