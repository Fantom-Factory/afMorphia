using afBeanUtils::TypeCoercer

internal const class BsonMapConverter : BsonConverter {
	private static const Regex			unicodeRegex	:= "\\\\u+[0-9a-fA-F]{4}".toRegex
	private static const Regex			unicodeRegex2	:= "\\\\u{2,}[0-9a-fA-F]{4}".toRegex
	private		   const TypeCoercer	typeCoercer
	
	new make() {
		this.typeCoercer = BsonTypeCoercer()
	}

	override Obj? toBsonVal(Obj? fantomObj, BsonConverterCtx ctx) {
		if (fantomObj == null) return null
		fanMap		:= (Obj:Obj?) fantomObj		// https://fantom.org/forum/topic/2768
		mapType		:= fanMap.typeof
		bsonObj		:= ctx.makeBsonObjFn
		// for-loop to cut down on func obj creation
		fanKeys	:= fanMap.keys
		for (i := 0; i < fanKeys.size; ++i) {
			fKey := fanKeys[i]
			fVal := fanMap[fKey]
			
			// Map keys are special and have to be converted <=> Str
			// As *anything* can be converter toStr(), let's check up front that we can convert it back to Fantom again!
			if (!typeCoercer.canCoerce(Str#, fKey.typeof))
				throw Err("Unsupported Map key type '${fKey.typeof.qname}', cannot coerce from Str#")
			
			mKey := encodeKey(typeCoercer.coerce(fKey, Str#))
			mVal := fVal == null ? null : ctx.makeMap(fVal.typeof, fanMap, fKey, fVal).toBsonVal
			bsonObj[mKey] = mVal
		}
		return bsonObj
	}
	
	override Obj? fromBsonVal(Obj? bsonVal, BsonConverterCtx ctx) {
		if (bsonVal == null) return null

		fanKeyType 	:= ctx.type.params["K"]
		fanValType 	:= ctx.type.params["V"]

		bsonObj		:= (Str:Obj?) bsonVal
		fanMap		:= ctx.makeMapFn
		// for-loop to cut down on func obj creation
		bsonKeys	:= bsonObj.keys
		for (i := 0; i < bsonKeys.size; ++i) {
			jKey := bsonKeys[i]
			jVal := bsonObj[jKey]
			
			// Map keys are special and have to be converted <=> Str
			fKey := decodeKey(typeCoercer.coerce(jKey, fanKeyType))
			fVal := ctx.makeMap(fanValType, bsonObj, jKey, jVal).fromBsonVal
			fanMap[fKey] = fVal
		}
		return fanMap
	}
	
	// http://stackoverflow.com/questions/21522770/unicode-escape-syntax-in-java
	internal static Str encodeKey(Str key) {
		buf		:= StrBuf(key.size + 5).add(key)
		matcher := unicodeRegex.matcher(key)
		idx		:= 0
		while (matcher.find) {
			buf.insert(matcher.start(0) + 1 + idx++, "u")
		}
		return buf.toStr.replace("\$", "\\u0024").replace(".", "\\u002e")
	}
	
	internal static Str decodeKey(Str key) {
		replace	:= key.replace("\\u002e", ".").replace("\\u0024", "\$")
		buf		:= StrBuf(replace.size).add(replace)
		matcher := unicodeRegex2.matcher(replace)
		idx		:= 0
		while (matcher.find) {
			buf.remove(matcher.start(0) + 1 + idx--)
		}
		return buf.toStr
	}
}
