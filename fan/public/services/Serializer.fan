using afIoc
using afMongo

const class Serializer {
	
	@Inject	private const Registry 		registry
	@Inject	private const Converters	converters

	new make(|This|in) { in(this) }
	
	** - surrogate static new fromMongo(Obj obj, XXX) -> overrides everything
	** - null
	** - literal
	** - entity -> Err for now
	** - surrogate new makeFromMongo(Obj obj, XXX, |This|in)
	** - embedded document
	Obj fromMongoDoc(Str:Obj? mongoDoc, Type type) {		
		maker := Maker(type)

		// TODO: validate entity type (cached)

		type.fields.each |field| {
			property := (Property?) Field#.method("facet").callOn(field, [Property#, false])
			if (property == null)
				return
			
			propName := field.name	// TODO: @Property property.name ?: field.name
			propVal  := mongoDoc.get(propName, null)
			
			implType := field.type	// TODO: @Property property.type ?: field.type

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

			
			converter := converters[implType]
			if (converter != null) {
				fieldVal := converter.toFantom(field, propVal)

				// TODO: converter Errs
//				if (fieldVal == null) {
//					if (!field.type.isNullable)
//						throw MorphiaErr(Msgs.serializer_staticCtorIsNull(staticCtor, field, logDoc(mongoDoc)))
//					else
//						maker[field] = fieldVal
//					return
//				}
//				if (!fieldVal.typeof.fits(field.type))
//					throw MorphiaErr(Msgs.serializer_staticCtorNotFitField(staticCtor, fieldVal.typeof, field, logDoc(mongoDoc)))				
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

			if (isMongoLiteralType(field.type)) {
				if (!propVal.typeof.fits(field.type))
					throw MorphiaErr(Msgs.serializer_propertyDoesNotFitField(propName, propVal.typeof, field, logDoc(mongoDoc)))
				maker[field] = propVal
				return
			}

			if (!implType.fits(field.type))	// could happen if we're using a surrogate
				throw MorphiaErr(Msgs.serializer_ctorNotFitField(implType, field, logDoc(mongoDoc)))

			if (implType.hasFacet(Document#))	// TODO: Entity -> Entity mapping 
				throw MorphiaErr("Entity -> Entity mapping not yet supported")
			
			ctor := implType.method("makeFromMongo", false)
			if (ctor != null) {
				if (!ctor.isCtor)
					throw MorphiaErr(Msgs.serializer_ctorIsNotCtor(ctor))
				if (ctor.isStatic)
					throw MorphiaErr(Msgs.serializer_ctorIsStatic(ctor))

				fieldVal := registry.callMethod(ctor, null, [propVal])				
				maker[field] = fieldVal
				return
			}

			maker[field] = fromMongoDoc(propVal, implType)
			return
			
			// TODO: recurse into lists & maps
			
			// TODO: have global try / catch to provide ctx			
		}
		
		return registry.autobuild(type, Obj#.emptyList, maker.vals)
	}
	
	Str:Obj? toMongoDoc(Obj entity) {
		mongoDoc := Str:Obj?[:]
		entity.typeof.fields.each |field| {
			property := (Property?) Field#.method("facet").callOn(field, [Property#, false])
			if (property == null)
				return

			fieldVal := field.get(entity)
			propName := field.name	// TODO: @Property property.name ?: field.name			
			implType := field.type	// TODO: @Property property.type ?: field.type
			
			method := implType.method("toMongo", false)
			if (method != null) {
				propVal := null
				
				if (method.isStatic)
					propVal = registry.callMethod(method, null, [fieldVal])
				else if (fieldVal != null)
					propVal = registry.callMethod(method, fieldVal, Obj#.emptyList)
					
				if (propVal == null) {
					// TODO: do NullStrategy
					mongoDoc[propName] = propVal
					return
				}

				if (!isMongoLiteral(propVal))
					throw MorphiaErr(Msgs.serializer_notMongoLiteral(propVal.typeof, field))				
				mongoDoc[propName] = propVal
				return
			}

			converter := converters[implType]
			Env.cur.err.printLine(converter)
			if (converter != null) {
				propVal := converter.toMongo(field, fieldVal)

				mongoDoc[propName] = propVal

//				if (propVal == null) {
//					// TODO: do NullStrategy
//					mongoDoc[propName] = propVal
//					return
//				}
				
				return
			}

			if (isMongoLiteralType(field.type)) {
				mongoDoc[propName] = fieldVal
				return
			}

			if (fieldVal == null) {
				propVal := fieldVal
				// TODO: do NullStrategy
				mongoDoc[propName] = propVal
				return
			}

			mongoDoc[propName] = toMongoDoc(fieldVal)
			return
			
			// TODO: recurse into lists & maps
			
			// TODO: have global try / catch to provide ctx			
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

	// TODO: move BSON literals and helper (isBson) methods to Mongo
	private static const Type[] literals	:= [Bool#, Buf#, Date#, DateTime#, Float#, Int#, List#, Map#, ObjectId#, Regex#, Str#]

	private Bool isMongoLiteralType(Type? type) {
		// TODO: recurse into lists & maps -> diff name, it's then not a literal!
		(type == null) ? true : literals.any { type.fits(it) } 		
	}

	private Bool isMongoLiteral(Obj? obj) {
		// TODO: recurse into lists & maps -> diff name, it's then not a literal!
		(obj == null) ? true : literals.any { obj.typeof.fits(it) }
	}
}
