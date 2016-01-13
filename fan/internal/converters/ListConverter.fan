using afIoc
using afBson

@NoDoc
const class ListConverter : Converter {

	@Inject private const |->Converters|	converters
	
	new make(|This|in) {
		in(this)
	}
	
	override Obj? toFantom(Type fanListType, Obj? mongoObj) {
		if (mongoObj == null) return null

		fanValType := fanListType.params["V"]
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
			fanList.addAll(mongoList.map { converters().toFantom(fanValType, it) })

		return fanList
	}
	
	override Obj? toMongo(Obj fantomObj) {
		fanList	 := (List) fantomObj
		listType := fanList.typeof
		
		// if the whole list is a valid BSON document, then return it as is
		if (!listType.isGeneric)
			if (BsonType.isBsonLiteral(listType) || fanList.all { BsonType.isBsonLiteral(it?.typeof) })
				return fantomObj
		
		
		return ((List) fantomObj).map { converters().toMongo(it) }
	}
}
