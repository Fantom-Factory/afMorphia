using afBeanUtils::ReflectUtils
using afIoc::Inject
using afIoc::Scope
using afBson::ObjectId

** The main converter for MongoDB documents. 
** 
** @see [Storing null vs not storing the key at all in MongoDB]`http://stackoverflow.com/questions/12403240/storing-null-vs-not-storing-the-key-at-all-in-mongodb` 
@NoDoc	// public so people can change the null strategy
const class ObjConverter : Converter {

	** If 'false' then properties with 'null' values are not stored in the database.
					const Bool				storeNullFields
	@Inject private const |->Scope|			activeScope
	@Inject private const |->Converters|	converters	// avoid circular dependencies
	@Inject private const PropertyCache		propertyCache

	** Creates a new 'ObjConverter' with the given 'null' strategy.
	** 
	** If 'storeNullFields' is 'false' then properties with 'null' values are not stored in the database.
	new make(Bool storeNullFields, |This|in) {
		this.storeNullFields = storeNullFields
		in(this) 
	}
	
	@NoDoc
	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		if (mongoObj == null) return null

		// because ObjConverter is a catch-all converter, we sometimes get sent here by mistake
		if (mongoObj.typeof.name != "Map")
			throw MorphiaErr(ErrMsgs.documentConv_noConverter(fantomType, mongoObj))

		mongoDoc	:= (Str:Obj?) mongoObj
		fieldVals	:= [Field:Obj?][:]

		if (mongoDoc.containsKey("_type"))
			fantomType = Type.find(mongoDoc["_type"])

		// TODO optionally throw an Err if we have unmapped Mongo data 
		
		findPropertyData(fantomType).each |field| {
			propName := field.name
			implType := field.type
			propVal  := mongoDoc.get(propName, null)
			fieldVal := converters().toFantom(implType, propVal)
			
			if (fieldVal == null && !field.type.isNullable) {
				defVal := field.defVal

				// if a value *is* required then decide which Err msg to throw 
				if (defVal == null)				
					if (mongoDoc.containsKey(propName))
						throw MorphiaErr(ErrMsgs.documentConv_propertyIsNull(propName, field.field, logDoc(mongoDoc)))
					else 
						throw MorphiaErr(ErrMsgs.documentConv_propertyNotFound(field.field, logDoc(mongoDoc)))

				fieldVal = defVal
			}
	
			// sanity check we're about to set the correct instance 
			if (fieldVal != null && !ReflectUtils.fits(fieldVal.typeof, field.type))
				throw MorphiaErr(ErrMsgs.documentConv_propertyDoesNotFitField(propName, fieldVal.typeof, field.field, logDoc(mongoDoc)))

			fieldVals[field.field] = fieldVal
		}
		
		return createEntity(fantomType, fieldVals)
	}
	
	@NoDoc
	override Obj? toMongo(Type type, Obj? fantomObj) {
		if (fantomObj == null) return null
		mongoDoc := createMongoDoc
		
		findPropertyData(fantomObj.typeof).each |field| {
			fieldVal := field.val(fantomObj)
			propName := field.name			
			implType := field.type
			defVal	 := field.defVal

			if (defVal == fieldVal)
				fieldVal = null
			
			// should we recursively convert...? 
			// note this should NOT use Utils.propertyType
			propVal	 := converters().toMongo(fieldVal?.typeof ?: field.type, fieldVal)			
			
			if (propVal == null && !storeNullFields)
				return

			// use add, rather than set, so an Err is thrown should we accidently try to add the 
			// same name twice (from using the Property@name facet)
			mongoDoc.add(propName, propVal)
		}

		return mongoDoc
	}

	private PropertyData[] findPropertyData(Type entityType) {
		propertyCache.getOrFindProperties(entityType)
	}
	
	** Creates an Entity instance using IoC. 
	** 
	** Override if you prefer your entities to be built by [BeanFactory]`afBeanUtils::BeanFactory`.
	virtual Obj? createEntity(Type type, Field:Obj? fieldVals) {
		activeScope().build(type, null, fieldVals)
	}
	
	** Creates an empty *ordered* Mongo document.
	** 
	** Override if you prefer your Mongo documents unordered or case-insensitive.
	virtual Str:Obj? createMongoDoc() {
		Str:Obj?[:] { it.ordered = true }
	}
	
	private static const Type[] literals	:= [Bool#, Buf#, Date#, DateTime#, Decimal#, Duration#, Enum#, Float#, Int#, ObjectId#, Regex#, Range#, Slot#, Str#, Type#]

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
