using afIoc
using afMongo

const class Serializer {

	private static const Type[] literals	:= [Bool#, Buf#, Date#, DateTime#, Float#, Int#, ObjectId#, Regex#, Str#]
	
	new make(|This|in) { in(this) }
	
	Obj fromMongoDoc(Str:Obj? mongoDoc, Type type) {		
		maker := Maker(type)
		
		type.fields.each |field| {
			property := (Property?) Field#.method("facet").callOn(field, [Property#, false])
			if (property == null)
				return
			
			propName := field.name	// TODO: @Property name
			propVal  := mongoDoc.get(propName, null)

			if (propVal == null) {
				if (!field.type.isNullable) {
					// a value *IS* required here, but as we have 'null', decide which Err msg to throw 
					if (!mongoDoc.containsKey(propName))
						throw MorphiaErr(Msgs.serializer_propertyNotFound(field, logDoc(mongoDoc)))
					else 
						throw MorphiaErr(Msgs.serializer_propertyIsNull(propName, field, logDoc(mongoDoc)))
				}
				maker[field] = propVal
				return
			}

			if (literals.contains(field.type.toNonNullable)) {
				if (propVal != null && !propVal.typeof.fits(field.type))
					throw MorphiaErr(Msgs.serializer_propertyDoesNotFitField(propName, propVal.typeof, field, logDoc(mongoDoc)))
				maker[field] = propVal
				return
			}

			
			
			maker[field] = fromMongoDoc(propVal, field.type)	// TODO: @Property implType
			return
			
			
			
			// TODO: what if data no-exist?
//			throw Err("WTF $field")
		}
		
		// TODO: will turn into IoC autobuild... somehow
		return maker.make
	}
	
	Str:Obj? toMongoDoc(Obj entity) {
		mongoDoc := Str:Obj?[:]
		entity.typeof.fields.each |field| {
			property := (Property?) Field#.method("facet").callOn(field, [Property#, false])
			if (property == null)
				return

			fieldVal := field.get(entity)

			if (literals.contains(field.type.toNonNullable)) {
				mongoDoc[field.name] = fieldVal
				return
			}

			if (fieldVal == null) {
				mongoDoc[field.name] = null
				return
			}

			mongoDoc[field.name] = toMongoDoc(fieldVal)
			return
			
			// TODO: what if data no-exist?
//			throw Err("WTF $field")
		}
		return mongoDoc
	}
	
	internal Str:Str logDoc(Str:Obj? document) {
		document.map |val->Str| {
			if (val == null)
				return "null"
			if (literals.contains(val.typeof.toNonNullable))
				return val.toStr
			return "..." 
		}
	}
}
