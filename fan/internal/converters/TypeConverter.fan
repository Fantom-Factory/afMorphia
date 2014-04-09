
internal const class TypeConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return Type.find((Str) mongoObj)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Type) fantomObj).qname
	}

}
