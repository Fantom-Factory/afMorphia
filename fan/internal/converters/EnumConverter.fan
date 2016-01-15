
internal const class EnumConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return type.method("fromStr").call(mongoObj, true)
	}
	
	override Obj? toMongo(Type type, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Enum) fantomObj).name
	}
}
