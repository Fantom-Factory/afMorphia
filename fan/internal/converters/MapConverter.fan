using afBeanUtils::TypeCoercer
using afBeanUtils::BeanFactory
using afIoc
using afBson

@NoDoc
const class MapConverter : Converter {

	@Inject 
	private const Converters 	converters
	private const TypeCoercer	typeCoercer
	
	new make(|This|in) {
		in(this)
		this.typeCoercer = CachingTypeCoercer()
	}	
	
	override Obj? toFantom(Type fanMapType, Obj? mongoObj) {
		if (mongoObj == null) return null

		fanKeyType 	:= fanMapType.params["K"]
		fanValType 	:= fanMapType.params["V"]

		mongoMap	:= (Map) mongoObj
		monMapType	:= mongoMap.typeof
		monKeyType 	:= monMapType.params["K"]
		monValType 	:= monMapType.params["V"]
		
		// monKeyType should always be Str#
		if (fanKeyType == Str# && monKeyType == Str#) {
			if (monValType.fits(fanValType))
				return mongoMap

			fanMap := makeMap(fanMapType)
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
		
		fanMap		:= makeMap(fanMapType)
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
			if (keyType == Str# && BsonType.isBsonLiteral(valType))
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
	
	** Creates an empty *ordered* Mongo document. 
	** 
	** Override for different behaviour. 
	virtual Str:Obj? emptyDoc() {
		Str:Obj?[:] { ordered = true }
	}

	** Creates an empty map for Fantom. Always creates an ordered map.
	** 
	** Override for different behaviour. 
	virtual Obj:Obj? makeMap(Type mapType) {
		((Map) BeanFactory.defaultValue(mapType, true)) {
			it.ordered = true
		}
	}
}
