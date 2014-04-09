
** Mongo literals pass straight through, as they're understood by the MongoDB driver.
internal const class LiteralConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) { mongoObj }

	override Obj? toMongo(Type type, Obj? fantomObj) { fantomObj }

}
