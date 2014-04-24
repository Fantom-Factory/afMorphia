using afIoc
using afBson

@NoDoc	// public so people can change the null strategy
const class MapConverter : Converter {

	@Inject 
	private const Converters 	converters
	private const TypeCoercer	typeCoercer
	private const Bool 			convertNullToEmptyMap
	
	new make(Bool convertNullToEmptyMap, |This|in) {
		in(this)
		this.convertNullToEmptyMap = convertNullToEmptyMap
		this.typeCoercer	= TypeCoercer()
	}	
	
	override Obj? toFantom(Type fanMapType, Obj? mongoObj) {
		fanKeyType 	:= fanMapType.params["K"]
		fanValType 	:= fanMapType.params["V"]

		if (mongoObj == null) 
			return convertNullToEmptyMap ? makeMap(fanMapType, fanKeyType) : null

		mongoMap	:= (Map) mongoObj
		monMapType	:= mongoMap.typeof
		monKeyType 	:= monMapType.params["K"]
		monValType 	:= monMapType.params["V"]
		
		// monKeyType should always be Str#
		if (fanKeyType == Str# && monKeyType == Str#) {
			if (monValType.fits(fanValType))
				return mongoMap

			fanMap := makeMap(fanMapType, fanKeyType)
			if (BsonType.isBsonLiteral(fanValType)) {
				// if the Fantom val type is BSON, just copy the vals over 'cos they wouldn't have changed
				fanMap.addAll(mongoMap)

			} else {
				// keep the keys, just convert the vals
				mongoMap.each |mVal, mKey| {
					fanMap[mKey] = converters.toFantom(fanValType, mVal)
				}				
			}
			return fanMap
		}
		
		fanMap		:= makeMap(fanMapType, fanKeyType)
		mongoMap.each |mVal, mKey| {
//			fKey := converters.toFantom(fanKeyType, mKey)
			fKey := typeCoercer.coerce(mKey, fanKeyType)
			fVal := converters.toFantom(fanValType, mVal)
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
		
		mongoMap	:= Str:Obj?[:] { ordered = true }
		fanMap.each |fVal, fKey| {
//			mKey := converters.toMongo(fKey)	// FIXME: to Str!! check we can convert back to Fantom!
			mKey := typeCoercer.coerce(fKey, Str#)
			mVal := converters.toMongo(fVal)
			mongoMap[mKey] = mVal
		}		
		return mongoMap
	}
	
	private static Map makeMap(Type mapType, Type keyType) {
		keyType.fits(Str#) ? Map.make(mapType) { caseInsensitive = true } : Map.make(mapType) { ordered = true }
	}
}
