
** Store Dates as DateTime objects so they can be sorted in MongoDB
internal const class DateConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return ((DateTime) mongoObj).date
	}
	
	override Obj? toMongo(Type type, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Date) fantomObj).toDateTime(Time.defVal)
	}
}
