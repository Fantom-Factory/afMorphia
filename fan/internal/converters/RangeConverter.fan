
internal const class RangeConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return Range.fromStr((Str) mongoObj)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Range) fantomObj).toStr
	}

}
