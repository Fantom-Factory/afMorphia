using afIoc
using afBson

@NoDoc	// public so people can change the null strategy
const class MapConverter : Converter {

	@Inject private const Converters 	converters
			private const Bool 			convertNullToEmptyMap
	
	new make(Bool convertNullToEmptyMap, |This|in) {
		in(this)
		this.convertNullToEmptyMap = convertNullToEmptyMap
	}	
	
	override Obj? toFantom(Type mapType, Obj? mongoObj) {
		keyType 	:= mapType.params["K"]

		if (mongoObj == null) 
			return convertNullToEmptyMap ? makeMap(mapType, keyType) : null

		mongoMap	:= (Map) mongoObj
		valType 	:= mapType.params["V"]
		
		// if the whole map is a valid BSON document, then return it as is
		if (keyType == Str# && BsonType.isBsonLiteral(valType))
			return mongoObj		
		
		fanMap		:= makeMap(mapType, keyType)
		mongoMap.each |mVal, mKey| {
			fKey := converters.toFantom(keyType, mKey)
			fVal := converters.toFantom(valType, mVal)
			fanMap[fKey] = fVal
		}
		return fanMap
	}
	
	override Obj? toMongo(Obj fantomObj) {
		fanMap		:= (Map) fantomObj
		mapType		:= fanMap.typeof
		
		// if the whole map is a valid BSON document, then return it as is
		if (!mapType.isGeneric) {
			keyType 	:= mapType.params["K"]
			valType 	:= mapType.params["V"]
			if (BsonType.isBsonLiteral(keyType) && BsonType.isBsonLiteral(valType))
				return fantomObj
		}
		
		mongoMap	:= Obj:Obj?[:]
		fanMap.each |fVal, fKey| {
			mKey := converters.toMongo(fKey)	// FIXME: to Str!! check we can convert back to Fantom!
			mVal := converters.toMongo(fVal)
			mongoMap[mKey] = mVal
		}		
		return mongoMap
	}
	
	private static Map makeMap(Type mapType, Type keyType) {
		keyType.fits(Str#) ? Map.make(mapType.toNonNullable) { caseInsensitive = true } : Map.make(mapType.toNonNullable) { ordered = true }
	}
}
