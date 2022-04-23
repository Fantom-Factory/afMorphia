using afBson::Binary
using afBson::MaxKey
using afBson::MinKey
using afBson::ObjectId
using afBson::Timestamp
using afBeanUtils::BeanBuilder

** (Service) - 
** Converts Fantom objects to and from their JSON representation.
const mixin BsonConvs {

	** Returns a new 'BsonConvs' instance.
	** 
	** If 'converters' is 'null' then 'defConvs' is used. Common options are:
	** 
	**   makeEntityFn      : |Type type, Field:Obj? fieldVals->Obj?| { BeanBuilder.build(type, vals) }
	**   storeNullFields   : false
	**   strictMode        : false
	**   propertyCache     : BsonPropCache()
	** 
	** Override 'makeEntity' to have IoC create entity instances.
	** Set 'strictMode' to 'true' to Err if the JSON contains unmapped data.
	** 
	** *Serializable Mode* is where all non-transient fields are converted, regardless of any '@BsonProp' facets. 
	** Data from '@BsonProp' facets, however, is still honoured if defined.
	static new make([Type:BsonConv]? converters := null, [Str:Obj?]? options := null) {
		BsonConvsImpl(converters ?: defConvs, options)
	}

	** Returns a new 'BsonConvs' whose options are overridden with the given ones.
	abstract BsonConvs withOptions(Str:Obj? newOptions)
	
	** Returns the 'Converter' instance used to convert the given type. 
	@Operator
	abstract BsonConv get(Type type)

	** The default set of JSON <-> Fantom converters.
	static Type:BsonConv defConvs() {
		BsonConvsImpl._defConvs
	}



	@NoDoc	// not sure why we'd want these to be pubic?
	internal abstract Obj? _toBsonCtx(Obj? fantomObj, BsonConvCtx ctx)

	@NoDoc	// not sure why we'd want these to be pubic?
	internal abstract Obj? _fromBsonCtx(Obj? bsonVal, BsonConvCtx ctx)
	
	

	** Converts the given Fantom object to its JSON representation.
	** 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	** 'fantomType' in case 'fantomObj' is null, but defaults to 'fantomObj?.typeof'. 
	abstract Obj? toBsonVal(Obj? fantomObj, Type? fantomType := null)
	
	** Converts a JSON value to the given Fantom type.
	** If 'fantomType' is 'null' then 'null' is always returned. 
	** 
	** 'bsonVal' is nullable so converters can choose whether or not to create empty lists and maps.
	abstract Obj? fromBsonVal(Obj? bsonVal, Type? fantomType)	

	
	
	** Converts the given Fantom object to its BSON object representation.
	** 
	** Convenience for calling 'toBsonVal()' with a cast.
	abstract [Str:Obj?]? toBsonDoc(Obj? fantomObj)
	
	** Converts a BSON object to the given Fantom type.
	** 
	** Convenience for calling 'fromBsonVal()' with a cast.
	abstract Obj? fromBsonDoc([Str:Obj?]? bsonObj, Type? fantomType)
	
	
	** Returns the 'BsonPropCache'.
	abstract BsonPropCache propertyCache()
}

internal const class BsonConvsImpl : BsonConvs {
	override const BsonPropCache	propertyCache
	 		 const BsonTypeLookup	typeLookup
			 const Unsafe			optionsRef	// use Unsafe because JS can't handle immutable functions

	new make(|This| f) { f(this) }
	
	new makeArgs(Type:BsonConv converters, [Str:Obj?]? options) {
		serializableMode := options?.get("serializableMode", false) == true
		this.typeLookup = BsonTypeLookup(converters)
		this.optionsRef	= Unsafe(Str:Obj?[
			"makeEntityFn"	: |Type type, Field:Obj? vals->Obj?| { BeanBuilder.build(type, vals) },
			"makeBsonObjFn"	: |->Str:Obj? | { Str:Obj?[:] { ordered = true } },
			"makeMapFn"		: |Type t->Map| { Map((t.isGeneric ? Obj:Obj?# : t).toNonNullable) { it.ordered = true } },
			"strictMode"	: false,
			"propertyCache"	: BsonPropCache(serializableMode),
		])
		
		if (options != null)
			this.optionsRef = Unsafe(this.options.rw.setAll(options))

		if (Env.cur.runtime != "js")
			// JS can't handle immutable functions, but I'd still like them to be thread safe in Java
			optionsRef = Unsafe(optionsRef.val.toImmutable)
		
		this.propertyCache	= this.options["propertyCache"]
	}

	Str:Obj? options() { optionsRef.val }
	
	override BsonConvs withOptions(Str:Obj? newOptions) {
		if (newOptions.containsKey("serializableMode")) {
			serializableMode := newOptions.get("serializableMode", false) == true
			newOptions["propertyCache"] = BsonPropCache(serializableMode)
		}
		return BsonConvsImpl {
			it.optionsRef		= Unsafe(this.options.rw.setAll(newOptions))
			it.propertyCache	= it.options["propertyCache"] ?: this.propertyCache
			it.typeLookup		= this.typeLookup
		}
	}
	
	override Obj? _toBsonCtx(Obj? fantomObj, BsonConvCtx ctx) {
		hookVal := ctx.toBsonHookFn(fantomObj)		
		return get(ctx.type).toBsonVal(fantomObj, ctx)
	}

	override Obj? _fromBsonCtx(Obj? bsonVal, BsonConvCtx ctx) {
		hookVal := ctx.fromBsonHookFn(bsonVal)
		return get(ctx.type).fromBsonVal(hookVal, ctx)
	}

	override Obj? toBsonVal(Obj? fantomObj, Type? fantomType := null) {
		if (fantomType == null) fantomType = fantomObj?.typeof
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := BsonConvCtx.makeTop(this, fantomType, fantomObj, options)
		return _toBsonCtx(fantomObj, ctx)
	}

	override Obj? fromBsonVal(Obj? bsonVal, Type? fantomType) {
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := BsonConvCtx.makeTop(this, fantomType, bsonVal, options)
		return _fromBsonCtx(bsonVal, ctx)
	}

	override [Str:Obj?]? toBsonDoc(Obj? fantomObj) {
		// let's not dick about - just convert null to null
		if (fantomObj == null) return null
		return toBsonVal(fantomObj, fantomObj.typeof)
	}
	
	override Obj? fromBsonDoc([Str:Obj?]? bsonVal, Type? fantomType) {
		fromBsonVal(bsonVal, fantomType)
	}

	override BsonConv get(Type type) {
		// if a specific converter can't be found then embed a record
		typeLookup.findParent(type)
	}
	
	static Type:BsonConv _defConvs() {
		config				:= Type:BsonConv[:]
		bsonLiteral			:= BsonLiteralConv()

		// BSON Literals - https://bson.org/
		config[Bool#]		= bsonLiteral
		config[Binary#]		= bsonLiteral
		config[Buf#]		= bsonLiteral
		config[DateTime#]	= bsonLiteral
		config[Float#]		= bsonLiteral
		config[Int#]		= bsonLiteral
		config[MaxKey#]		= bsonLiteral
		config[MinKey#]		= bsonLiteral
		config[ObjectId#]	= bsonLiteral
		config[Regex#]		= bsonLiteral
		config[Str#]		= bsonLiteral
		config[Timestamp#]	= bsonLiteral
		
		// Containers
		config[Obj#]		= BsonObjConv()
		config[Map#]		= BsonMapConv()
		config[List#]		= BsonListConv()

		// Fantom Literals
		config[Date#]		= BsonDateConv()
		config[Decimal#]	= BsonSimpleConv(Decimal#)
		config[Depend#]		= BsonSimpleConv(Depend#)
		config[Duration#]	= BsonSimpleConv(Duration#)
		config[Enum#]		= BsonEnumConv()
		config[Locale#]		= BsonSimpleConv(Locale#)
		config[MimeType#]	= BsonSimpleConv(MimeType#)
		config[Range#]		= BsonSimpleConv(Range#)
		config[Slot#]		= BsonSlotConv()
		config[Time#]		= BsonSimpleConv(Time#)
		config[TimeZone#]	= BsonSimpleConv(TimeZone#)
		config[Type#]		= BsonTypeConv()
		config[Unit#]		= BsonSimpleConv(Unit#)
		config[Uri#]		= BsonSimpleConv(Uri#)
		config[Uuid#]		= BsonSimpleConv(Uuid#)
		config[Version#]	= BsonSimpleConv(Version#)
		
		return config
	}
}
