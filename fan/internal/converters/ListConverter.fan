using afIoc

internal const class ListConverter : Converter {

	@Inject private const Serialiser serialiser
	
	new make(|This|in) { in(this) }
	
	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		listType 	:= fantomType.params["V"]
		mongoList	:= (List?) mongoObj
		fanList		:= List(listType, mongoList.size)
		// TODO: what if val is a complicated type
		fanList.addAll(mongoList.map { serialiser.toFantom(listType, it) })
		return fanList
	}
	
	override Obj? toMongo(Type type, Obj? fantomObj) {
		listType := type.params["V"]
		// TODO: what if val is a complicated type
		return ((List?) fantomObj)?.map { serialiser.toMongo(it?.typeof ?: listType, it) }
	}
}
