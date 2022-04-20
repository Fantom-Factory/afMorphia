
** Passed to 'BsonConverters' to give context on what they're converting.
class BsonConverterCtx {
	BsonConverterCtx?	parent	{ private set }
		  Type			type	{ private set }
	
	const Bool			isField
	const Field?		field
	const BsonProperty?	bsonProperty
		  Obj?			obj		{ private set }
	
	const Bool			isMap
	const Obj?			mapKey
		  Map?			map		{ private set }
	
	const Bool			isList
	const Int?			listIdx
		  List?			list	{ private set }

		  Str:Obj?		options
	
	private BsonConverters	converters

	private new make(|This| f) { f(this) }

	internal new makeTop(BsonConverters converters, Type type, Obj? obj, Str:Obj? options) {
		this.converters = converters
		this.type		= type
		this.obj		= obj
		this.options	= options
	}

	This makeField(Type type, Field field, BsonProperty? bsonProperty, Obj? obj) {
		// pass type, because the impl type may be different to the defined field.type
		BsonConverterCtx {
			it.parent		= this
			it.type			= type
			it.isField		= true
			it.field		= field
			it.bsonProperty	= bsonProperty
			it.obj			= obj
			it.converters	= this.converters
			it.options		= this.options
		}
	}

	This makeMap(Type type, Map map, Obj key, Obj? obj) {
		BsonConverterCtx {
			it.parent		= this
			it.type			= type
			it.isMap		= true
			it.map			= map
			it.mapKey		= key
			it.obj			= obj
			it.converters	= this.converters
			it.options		= this.options
		}
	}

	This makeList(Type type, List list, Int idx, Obj? obj) {
		BsonConverterCtx {
			it.parent		= this
			it.type			= type
			it.isList		= true
			it.list			= list
			it.listIdx		= idx
			it.obj			= obj
			it.converters	= this.converters
			it.options		= this.options
		}
	}	

	Bool isTopLevel() {
		parent == null
	}
	
	** Uses *this* context to convert 'this.obj'.
	Obj? toBsonVal() {
		converters._toBsonCtx(obj, this)
	}

	** Uses *this* context to convert 'this.obj'.
	Obj? fromBsonVal() {
		converters._fromBsonCtx(obj, this)
	}
	
	** Replace 'type' with a more specific subclass type.
	Void replaceType(Type newType) {
		if (!newType.fits(type))
			throw Err("Replacement types must be a Subtype: $newType -> $type")
		this.type = newType
	}
	
	// ---- Option Functions ----
	
	** Creates an empty *ordered* bson object. 
	@NoDoc Str:Obj? fnMakeBsonObj() {
		((|BsonConverterCtx->Str:Obj?|) options["afBson.makeBsonObj"])(this)
	}

	** Creates an Entity instance. 
	@NoDoc Obj? fnMakeEntity(Field:Obj? fieldVals) {
		((|Type, Field:Obj?, BsonConverterCtx->Obj?|) options["afBson.makeEntity"])(this.type, fieldVals, this)
	}

	** Creates an empty map for Fantom.
	@NoDoc Obj:Obj? fnMakeMap() {
		((|Type,BsonConverterCtx->Obj:Obj?|) options["afBson.makeMap"])(this.type, this)
	}
	
	** This is called *before* any 'bsonVal' is converted. 
	@NoDoc Obj? fnFromBsonHook(Obj? bsonVal) {
		((|Obj?, BsonConverterCtx->Obj?|?) options["afBson.fromBsonHook"])?.call(bsonVal, this) ?: bsonVal
	}
	
	** This is called *before* any 'fantomObj' is converted. 
	@NoDoc Obj? fnToBsonHook(Obj? fantomObj) {
		((|Obj?, BsonConverterCtx->Obj?|?) options["afBson.toBsonHook"])?.call(fantomObj, this) ?: fantomObj
	}
	
	** Returns the 'BsonPropertyCache'.
	@NoDoc BsonPropertyCache optBsonPropertyCache() {
		options["afBson.propertyCache"]
	}
	
	** Returns strict mode.
	@NoDoc Bool optStrictMode() {
		options.get("afBson.strictMode", false)
	}
	
	** Returns the Date format, with an ISO default if unspecified.
	@NoDoc Str optDateFormat() {
		options.get("afBson.dateFormat", "YYYY-MM-DD")
	}

	** Returns the DateTime format, with an ISO default if unspecified.
	@NoDoc Str optDateTimeFormat() {
		options.get("afBson.dateTimeFormat", "YYYY-MM-DD'T'hh:mm:ss.FFFz zzzz")
	}
}
