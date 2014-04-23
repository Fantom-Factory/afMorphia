using afIoc
using afBson

@NoDoc	// public so people can change the null strategy
const class ListConverter : Converter {

	@Inject private const Converters 	converters
			private const Bool 			convertNullToEmptyList
	
	new make(Bool convertNullToEmptyList, |This|in) {
		in(this)
		this.convertNullToEmptyList = convertNullToEmptyList
	}
	
	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		listType 	:= fantomType.params["V"]

		if (mongoObj == null)
			// as most entities are const, don't allocate any capacity to the list
			return convertNullToEmptyList ? List(listType, 0) : null
		mongoList	:= (List) mongoObj

		// if the whole list is a valid BSON document, then return it as is
		if (BsonType.isBsonLiteral(listType))
			return mongoObj

		fanList		:= List(listType, mongoList.size)
		fanList.addAll(mongoList.map { converters.toFantom(listType, it) })
		return fanList
	}
	
	override Obj? toMongo(Obj fantomObj) {
		fanList	 := (List) fantomObj
		listType := fanList.typeof
		
		// if the whole list is a valid BSON document, then return it as is
		if (!listType.isGeneric)
			if (BsonType.isBsonLiteral(listType) || fanList.all { BsonType.isBsonLiteral(it?.typeof) })
				return fantomObj
		
		
		return ((List) fantomObj).map { converters.toMongo(it) }
	}
}
