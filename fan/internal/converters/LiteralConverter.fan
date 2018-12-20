using afBson::Binary
//using afBeanUtils::TypeCoercer

** Mongo literals pass straight through, as they're understood by the MongoDB driver.
internal const class LiteralConverter : Converter {
	
//	private static const TypeCoercer typeCoercer := TypeCoercer()

	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		// if the Binary type is BIN_GENERIC then afBSON returns a Buf not a Binary,
		// so we re-inflate the Binary obj here
		if (fantomType == Binary# && mongoObj is Buf)
			return Binary((Buf) mongoObj)
		return mongoObj
		// Chg: 'LiteralConverter' now uses 'TypeCoercer' - useful for converting JSON documents. (Thanks LightDye!)
//		return typeCoercer.coerce(mongoObj, fantomType)
	}

	override Obj? toMongo(Type type, Obj? fantomObj) { fantomObj }

}
