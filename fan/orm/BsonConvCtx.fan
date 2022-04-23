
** Passed to 'BsonConvs' to give context on what they're converting.
class BsonConvCtx {
	BsonConvCtx?		parent	{ private set }
		  Type			type	{ private set }
	
	const Bool			isField
	const Field?		field
	const BsonProp?		bsonProperty
		  Obj?			obj		{ private set }
	
	const Bool			isMap
	const Obj?			mapKey
		  Map?			map		{ private set }
	
	const Bool			isList
	const Int?			listIdx
		  List?			list	{ private set }

		  Str:Obj?		options
	
	private BsonConvs	converters

	private new make(|This| f) { f(this) }

	internal new makeTop(BsonConvs converters, Type type, Obj? obj, Str:Obj? options) {
		this.converters = converters
		this.type		= type
		this.obj		= obj
		this.options	= options
	}

	This makeField(Type type, Field field, BsonProp? bsonProperty, Obj? obj) {
		// pass type, because the impl type may be different to the defined field.type
		BsonConvCtx {
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
		BsonConvCtx {
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
		BsonConvCtx {
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
	@NoDoc Str:Obj? makeBsonObjFn() {
		((|BsonConvCtx->Str:Obj?|) options["makeBsonObjFn"])(this)
	}

	** Creates an Entity instance. 
	@NoDoc Obj? makeEntityFn(Field:Obj? fieldVals) {
		((|Type, Field:Obj?, BsonConvCtx->Obj?|) options["makeEntityFn"])(this.type, fieldVals, this)
	}

	** Creates an empty map for Fantom.
	@NoDoc Obj:Obj? makeMapFn() {
		((|Type,BsonConvCtx->Obj:Obj?|) options["makeMapFn"])(this.type, this)
	}
	
	** This is called *before* any 'bsonVal' is converted. 
	@NoDoc Obj? fromBsonHookFn(Obj? bsonVal) {
		((|Obj?, BsonConvCtx->Obj?|?) options["fromBsonHookFn"])?.call(bsonVal, this) ?: bsonVal
	}
	
	** This is called *before* any 'fantomObj' is converted. 
	@NoDoc Obj? toBsonHookFn(Obj? fantomObj) {
		((|Obj?, BsonConvCtx->Obj?|?) options["toBsonHookFn"])?.call(fantomObj, this) ?: fantomObj
	}
	
	** Returns the 'BsonPropCache'.
	@NoDoc BsonPropCache optBsonPropCache() {
		options["propertyCache"]
	}
	
	** Returns strict mode.
	@NoDoc Bool optStrictMode() {
		options.get("strictMode", false)
	}
	
	@NoDoc Bool optStoreNullFields() {
		options.get("storeNullFields", false)
	}
}
