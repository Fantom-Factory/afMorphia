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
	
	override Obj? toFantom(Type fanListType, Obj? mongoObj) {
		fanValType := fanListType.params["V"]

		if (mongoObj == null)
			// as most entities are const, don't allocate any capacity to the list
			return convertNullToEmptyList ? List(fanValType, 0) : null

		mongoList	:= (List) mongoObj
		monListType	:= mongoList.typeof
		monValType	:= monListType.params["V"]
		
		// if the whole list is a valid BSON document, then return it as is
		if (monValType.fits(fanValType))
			return mongoList
		
		fanList		:= List(fanValType, mongoList.size)
		if (BsonType.isBsonLiteral(fanValType))
			fanList.addAll(mongoList)
		else
			fanList.addAll(mongoList.map { converters.toFantom(fanValType, it) })

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
