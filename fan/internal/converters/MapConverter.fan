using afIoc

internal const class MapConverter : Converter {

	@Inject private const Converters converters
	
	new make(|This|in) { in(this) }
	
	override Obj? toFantom(Type mapType, Obj? mongoObj) {
		if (mongoObj == null)	return null
		keyType 	:= mapType.params["K"]
		valType 	:= mapType.params["V"]
		mongoMap	:= (Map?) mongoObj
		fanMap		:= keyType.fits(Str#) ? Map.make(mapType.toNonNullable) { caseInsensitive = true } : Map.make(mapType.toNonNullable) { ordered = true }
		mongoMap.each |mVal, mKey| {
			fKey := converters.toFantom(keyType, mKey)
			fVal := converters.toFantom(valType, mVal)
			fanMap[fKey] = fVal
		}
		return fanMap
	}
	
	override Obj? toMongo(Type mapType, Obj? fantomObj) {
		keyType 	:= mapType.params["K"]
		valType 	:= mapType.params["V"]
		fanMap		:= (Map?) fantomObj
		mongoMap	:= Obj:Obj?[:]
		fanMap?.each |fVal, fKey| {
			mKey := converters.toMongo(keyType, fKey)
			mVal := converters.toMongo(valType, fVal)
			mongoMap[mKey] = mVal
		}		
		return mongoMap
	}
	
	static Void main(Str[] args) {
	  mapType := Map?#
	  map := Map(mapType)
	}
}
