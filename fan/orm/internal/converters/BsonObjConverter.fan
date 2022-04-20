using afBeanUtils::ReflectUtils

** The main converter for JSON objects. 
internal const class BsonObjConverter : BsonConverter {

	@NoDoc
	override Obj? toBsonVal(Obj? fantomObj, BsonConverterCtx ctx) {
		if (fantomObj == null) return null
		bsonObj := ctx.makeBsonObjFn
		
		ctx.optBsonPropertyCache.getOrFindTags(fantomObj.typeof, ctx).each |field| {
			fieldVal := field.val(fantomObj)
			propName := field.name			
			defVal	 := field.defVal
//			implType := field.type	// it is safer to convert what we actually have
			implType := fieldVal?.typeof ?: field.type

			if (defVal == fieldVal)
				fieldVal = null

			propVal	 := ctx.makeField(implType, field.field, field.bsonProperty, fieldVal).toBsonVal
			
			// save DB fields, don't store nulls!
			if (propVal == null && ctx.optStoreNullFields == false)
				return

			// use add, rather than set, so an Err is thrown should we accidently try to add the 
			// same name twice (from using the Property@name facet)
			bsonObj.add(propName, propVal)
		}

		return bsonObj
	}

	@NoDoc
	override Obj? fromBsonVal(Obj? bsonVal, BsonConverterCtx ctx) {
		if (bsonVal == null) return null

		// because ObjConverter is a catch-all Obj converter, we sometimes get sent here when a specific converter can't be found
		// in which case, the sanity check below throws a really good err msg which should be understood by the user
		// so no real need for the extra procoessing here 
//		if (bsonVal isnot Map && !ReflectUtils.fits(bsonVal.typeof, fantomType))
//			throw Err(documentConv_noConverter(fantomType, bsonVal))

		// we get sent to ObjConverter when the field type is 'Obj?' - so just return the JSON literal
		if (bsonVal isnot Map)
			return bsonVal

		bsonObj		:= (Str:Obj?) bsonVal
		fieldVals	:= [Field:Obj?][:]

		if (bsonObj.containsKey("_type"))
			// we *should* set _type if we can, it's expected behaviour and there's no reason not to
			ctx.replaceType(Type.find(bsonObj.get("_type")))	
			
		tagData := ctx.optBsonPropertyCache.getOrFindTags(ctx.type, ctx)
		
		if (ctx.optStrictMode) {
			tagNames := tagData.map { it.name }
			keyNames := bsonObj.keys
			keyNames = keyNames.removeAll(tagNames)
			if (keyNames.size > 0)
				throw Err("Extraneous data in BSON object for ${ctx.type.qname}: " + keyNames.join(", "))
		}

		// we can't instantiate 'Obj' so just return wot we got
		// this is important to LspRpc testing - and just makes sense
		// I mean, why should we throw an error when we already have an obj?
		if (ctx.type.toNonNullable == Obj#)
			return bsonVal
		
		// for-loop to cut down on func obj creation
		for (i := 0; i < tagData.size; ++i) {
			field	 := tagData[i]
			propName := field.name
			implType := field.type
			propVal  := bsonObj.get(propName, null)

			fieldVal := ctx.makeField(implType, field.field, field.bsonProperty, propVal).fromBsonVal

			if (fieldVal == null && !field.type.isNullable) {
				defVal := field.defVal

				// if a value *is* required then decide which Err msg to throw 
				if (defVal == null)				
					if (bsonObj.containsKey(propName))
						throw Err(stripSys("BSON property ${propName} is null but field ${field.field.qname} is NOT nullable : ${logRec(bsonObj)}"))
					else 
						throw Err(stripSys("BSON property does not contain a property for field ${field.field.qname} : ${logRec(bsonObj)}"))

				fieldVal = defVal
			}
	
			// sanity check we're about to set the correct instance 
			if (fieldVal != null && !ReflectUtils.fits(fieldVal.typeof, field.type))
				throw Err(stripSys("BSON property ${propName} of type ${fieldVal.typeof.signature} does not fit field ${field.field.qname} of type ${field.field.type.signature} : ${logRec(bsonObj)}"))

			if (field.field.isConst)	// todo I should test this! Needed when we inject Maps into const fields (in a non-const object)
				fieldVal = fieldVal.toImmutable
			fieldVals[field.field] = fieldVal
		}
		
		return ctx.makeEntityFn(fieldVals)
	}

	private static const Type[] literals	:= [Bool#, Date#, DateTime#, Str#, Time#, Uri#, Depend#, Decimal#, Duration#, Enum#, Float#, Int#, Locale#, MimeType#, Range#, Regex#, Slot#, TimeZone#, Type#, Unit#, Version#]
	private Str:Str logRec(Map obj) {
		obj.map |val->Str| {
			if (val == null)
				return "null"
			if (literals.contains(val.typeof.toNonNullable))
				return val.toStr
			return "..." 
		}
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
