using afIoc

internal const class ListConverter : Converter {

	@Inject private const Converters converters
	
	new make(|This|in) { in(this) }
	
	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		listType 	:= fantomType.params["V"]
		mongoList	:= (List?) mongoObj
		fanList		:= List(listType, mongoList.size)
		fanList.addAll(mongoList.map { converters.toFantom(listType, it) })
		return fanList
	}
	
	override Obj? toMongo(Type type, Obj? fantomObj) {
		listType	:= type.params["V"]
		fanList		:= (List?) fantomObj
		// use 'typeof' 
		return fanList?.map { converters.toMongo(it?.typeof ?: listType, it) }
	}
}
