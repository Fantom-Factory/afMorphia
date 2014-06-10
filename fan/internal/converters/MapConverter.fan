using afBeanUtils::TypeCoercer
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
		this.typeCoercer	= CachingTypeCoercer()
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
			// Map keys are special and have to be converted <=> Str
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
		
		mongoMap	:= emptyDoc
		fanMap.each |fVal, fKey| {
			// Map keys are special and have to be converted <=> Str
			// As *anything* can be converter toStr(), let's check up front that we can convert it back to Fantom again!
			if (!typeCoercer.canCoerce(Str#, fKey.typeof))
				throw MorphiaErr(ErrMsgs.mapConverter_cannotCoerceKey(fKey.typeof))
			mKey := typeCoercer.coerce(fKey, Str#)
			mVal := converters.toMongo(fVal)
			mongoMap[mKey] = mVal
		}		
		return mongoMap
	}
	
	** Creates an empty *ordered* Mongo document. Override if you want different defaults.
	protected virtual Str:Obj? emptyDoc() {
		Str:Obj?[:] { ordered = true }
	}

	private static Map makeMap(Type mapType, Type keyType) {
		// see http://fantom.org/sidewalk/topic/2256
		keyType.fits(Str#) ? Map.make(mapType.toNonNullable) { caseInsensitive = true } : Map.make(mapType.toNonNullable) { ordered = true }
	}
}
