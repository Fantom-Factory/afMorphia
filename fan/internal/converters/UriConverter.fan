
internal const class UriConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return ((Str) mongoObj).toUri
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Uri) fantomObj).toStr
	}

}
