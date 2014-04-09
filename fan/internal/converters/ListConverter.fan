using afIoc

internal const class ListConverter : Converter {

	@Inject private const Converters converters
	
	new make(|This|in) { in(this) }
	
	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		// TODO: List strategy
		if (mongoObj == null) return null

		listType 	:= fantomType.params["V"]
		mongoList	:= (List) mongoObj
		fanList		:= List(listType, mongoList.size)
		fanList.addAll(mongoList.map { converters.toFantom(listType, it) })
		return fanList
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((List) fantomObj).map { converters.toMongo(it) }
	}
}
