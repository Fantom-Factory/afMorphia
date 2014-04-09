using afIoc
using afMongo

internal const class DocumentConverter : Converter {

	@Inject private const Registry registry
	@Inject private const Converters converters
	
	new make(|This|in) { in(this) }
	
	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		if (mongoObj == null)	return null

		fieldVals	:= [Field:Obj?][:]
		mongoDoc	:= (Str:Obj?) mongoObj

		fantomType.fields.each |field| {
			property := (Property?) Field#.method("facet").callOn(field, [Property#, false])
			if (property == null)
				return
			
			propName := field.name	// TODO: @Property property.name ?: field.name
			propVal  := mongoDoc.get(propName, null)
			implType := field.type	// TODO: @Property property.type ?: field.type
			
			fieldVal := converters.toFantom(implType, propVal)
			
			if (fieldVal == null && !field.type.isNullable) {
				// a value *is* required so decide which Err msg to throw 
				if (!mongoDoc.containsKey(propName))
					throw MorphiaErr(Msgs.serializer_propertyNotFound(field, logDoc(mongoDoc)))
				else 
					throw MorphiaErr(Msgs.serializer_propertyIsNull(propName, field, logDoc(mongoDoc)))
			}
	
			// for .toNonNullable see http://fantom.org/sidewalk/topic/2256
			if (fieldVal != null && !fieldVal.typeof.toNonNullable.fits(field.type.toNonNullable)) {
				throw MorphiaErr(Msgs.serializer_propertyDoesNotFitField(propName, fieldVal.typeof, field, logDoc(mongoDoc)))
			}

			fieldVals[field] = fieldVal
		}
		
		return registry.autobuild(fantomType, Obj#.emptyList, fieldVals)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		mongoDoc := Str:Obj?[:]
		
		fantomObj.typeof.fields.each |field| {
			property := (Property?) Field#.method("facet").callOn(field, [Property#, false])
			if (property == null)
				return

			fieldVal := field.get(fantomObj)
			propName := field.name	// TODO: @Property property.name ?: field.name			
			
			propVal	 := converters.toMongo(fieldVal)			
			
			if (propVal == null) {
				// TODO: do NullStrategy -> no custom, just do or don't
				return
			}

			mongoDoc[propName] = propVal			
		}

		return mongoDoc
	}

	
	private static const Type[] literals	:= [Bool#, Buf#, Date#, DateTime#, Float#, Int#, List#, Map#, ObjectId#, Regex#, Str#]

	private Str:Str logDoc(Str:Obj? document) {
		document.map |val->Str| {
			if (val == null)
				return "null"
			if (literals.contains(val.typeof.toNonNullable))
				return val.toStr
			return "..." 
		}
	}
}
