
internal const class DecimalConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return Decimal.fromStr((Str) mongoObj)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Decimal) fantomObj).toStr
	}

}
