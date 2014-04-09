
internal const class DurationConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return Duration.fromStr((Str) mongoObj)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Duration) fantomObj).toStr
	}

}
