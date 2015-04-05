
internal const class EnumConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return type.method("fromStr").call(mongoObj, true)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Enum) fantomObj).name
	}

}
