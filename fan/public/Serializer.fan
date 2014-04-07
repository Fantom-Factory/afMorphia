using afIoc
using afMongo

const class Serializer {

	private static const Type[] literals	:= [Bool#, Buf#, Date#, DateTime#, Float#, Int#, ObjectId#, Regex#, Str#]
	
	@Inject	private const Registry registry
	
	new make(|This|in) { in(this) }
	
	** - surrogate static new fromMongo(Obj obj, XXX) -> overrides everything
	** - impl static new fromMongo(Obj obj, XXX) -> overrides everything
	** - null
	** - literal
	** - entity -> Err for now
	** - surrogate new makeFromMongo(Obj obj, XXX, |This|in)
	** - impl new makeFromMongo(Obj obj, XXX, |This|in)
	** - embedded document
	Obj fromMongoDoc(Str:Obj? mongoDoc, Type type) {		
		maker := Maker(type)

		// TODO: validate entity type (cached)

		type.fields.each |field| {
			property := (Property?) Field#.method("facet").callOn(field, [Property#, false])
			if (property == null)
				return
			
			propName := field.name	// TODO: @Property name
			propVal  := mongoDoc.get(propName, null)
			
			implType := property.surrogate ?: field.type

			staticCtor := implType.method("fromMongo", false)
			if (staticCtor != null) {
				if (!staticCtor.isStatic)
					throw MorphiaErr(Msgs.serializer_staticCtorIsNotStatic(staticCtor))

				fieldVal := registry.callMethod(staticCtor, null, [propVal])
				
				if (fieldVal == null) {
					if (!field.type.isNullable)
						throw MorphiaErr(Msgs.serializer_staticCtorIsNull(staticCtor, field, logDoc(mongoDoc)))
					else
						maker[field] = fieldVal
					return
				}
				if (!fieldVal.typeof.fits(field.type))
					throw MorphiaErr(Msgs.serializer_staticCtorNotFitField(staticCtor, fieldVal.typeof, field, logDoc(mongoDoc)))				
				maker[field] = fieldVal
				return
			}
			
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
				if (!propVal.typeof.fits(field.type))
					throw MorphiaErr(Msgs.serializer_propertyDoesNotFitField(propName, propVal.typeof, field, logDoc(mongoDoc)))
				maker[field] = propVal
				return
			}
	
			ctor := implType.method("makeFromMongo", false)
			if (ctor != null) {
				if (!implType.fits(field.type))	// could happen if we're using a surrogate
					throw MorphiaErr(Msgs.serializer_ctorNotFitField(implType, field, logDoc(mongoDoc)))
				if (!ctor.isCtor)
					throw MorphiaErr(Msgs.serializer_ctorIsNotCtor(ctor))
				if (ctor.isStatic)
					throw MorphiaErr(Msgs.serializer_ctorIsStatic(ctor))

				fieldVal := registry.callMethod(ctor, null, [propVal])				
				maker[field] = fieldVal
				return
			}

			maker[field] = fromMongoDoc(propVal, field.type)	// TODO: @Property implType
			return
			
			// TODO: have global try / catch to provide ctx
			
			// TODO: what if data no-exist?
//			throw Err("WTF $field")
		}
		
		// TODO: turn into IoC autobuild... somehow
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
