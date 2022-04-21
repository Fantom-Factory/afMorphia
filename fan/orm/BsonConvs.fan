using afBson::Binary
using afBson::MaxKey
using afBson::MinKey
using afBson::ObjectId
using afBson::Timestamp
using afBeanUtils::BeanBuilder

** (Service) - 
** Converts Fantom objects to and from their JSON representation.
const mixin BsonConverters {

	** Returns a new 'BsonConverters' instance.
	** 
	** If 'converters' is 'null' then 'defConvs' is used. Common options are:
	** 
	**   makeEntityFn      : |Type type, Field:Obj? fieldVals->Obj?| { BeanBuilder.build(type, vals) }
	**   storeNullFields   : false
	**   strictMode        : false
	**   propertyCache     : BsonPropertyCache()
	** 
	** Override 'makeEntity' to have IoC create entity instances.
	** Set 'strictMode' to 'true' to Err if the JSON contains unmapped data.
	** 
	** *Serializable Mode* is where all non-transient fields are converted, regardless of any '@BsonProperty' facets. 
	** Data from '@BsonProperty' facets, however, is still honoured if defined.
	static new make([Type:BsonConverter]? converters := null, [Str:Obj?]? options := null) {
		BsonConvertersImpl(converters ?: defConvs, options)
	}

	** Returns a new 'BsonConverters' whose options are overridden with the given ones.
	abstract BsonConverters withOptions(Str:Obj? newOptions)
	
	** Returns the 'Converter' instance used to convert the given type. 
	@Operator
	abstract BsonConverter get(Type type)

	** The default set of JSON <-> Fantom converters.
	static Type:BsonConverter defConvs() {
		BsonConvertersImpl._defConvs
	}



	@NoDoc	// not sure why we'd want these to be pubic?
	internal abstract Obj? _toBsonCtx(Obj? fantomObj, BsonConverterCtx ctx)

	@NoDoc	// not sure why we'd want these to be pubic?
	internal abstract Obj? _fromBsonCtx(Obj? bsonVal, BsonConverterCtx ctx)
	
	

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
	
	
	** Returns the 'BsonPropertyCache'.
	abstract BsonPropertyCache propertyCache()
}

internal const class BsonConvertersImpl : BsonConverters {
	override const BsonPropertyCache	propertyCache
	 		 const BsonTypeLookup		typeLookup
			 const Unsafe				optionsRef	// use Unsafe because JS can't handle immutable functions

	new make(|This| f) { f(this) }
	
	new makeArgs(Type:BsonConverter converters, [Str:Obj?]? options) {
		serializableMode := options?.get("serializableMode", false) == true
		this.typeLookup = BsonTypeLookup(converters)
		this.optionsRef	= Unsafe(Str:Obj?[
			"makeEntityFn"	: |Type type, Field:Obj? vals->Obj?| { BeanBuilder.build(type, vals) },
			"makeBsonObjFn"	: |->Str:Obj? | { Str:Obj?[:] { ordered = true } },
			"makeMapFn"		: |Type t->Map| { Map((t.isGeneric ? Obj:Obj?# : t).toNonNullable) { it.ordered = true } },
			"strictMode"	: false,
			"propertyCache"	: BsonPropertyCache(serializableMode),
		])
		
		if (options != null)
			this.optionsRef = Unsafe(this.options.rw.setAll(options))

		if (Env.cur.runtime != "js")
			// JS can't handle immutable functions, but I'd still like them to be thread safe in Java
			optionsRef = Unsafe(optionsRef.val.toImmutable)
		
		this.propertyCache	= this.options["propertyCache"]
	}

	Str:Obj? options() { optionsRef.val }
	
	override BsonConverters withOptions(Str:Obj? newOptions) {
		if (newOptions.containsKey("serializableMode")) {
			serializableMode := newOptions.get("serializableMode", false) == true
			newOptions["propertyCache"] = BsonPropertyCache(serializableMode)
		}
		return BsonConvertersImpl {
			it.optionsRef		= Unsafe(this.options.rw.setAll(newOptions))
			it.propertyCache	= it.options["propertyCache"] ?: this.propertyCache
			it.typeLookup		= this.typeLookup
		}
	}
	
	override Obj? _toBsonCtx(Obj? fantomObj, BsonConverterCtx ctx) {
		hookVal := ctx.toBsonHookFn(fantomObj)		
		return get(ctx.type).toBsonVal(fantomObj, ctx)
	}

	override Obj? _fromBsonCtx(Obj? bsonVal, BsonConverterCtx ctx) {
		hookVal := ctx.fromBsonHookFn(bsonVal)
		return get(ctx.type).fromBsonVal(hookVal, ctx)
	}

	override Obj? toBsonVal(Obj? fantomObj, Type? fantomType := null) {
		if (fantomType == null) fantomType = fantomObj?.typeof
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := BsonConverterCtx.makeTop(this, fantomType, fantomObj, options)
		return _toBsonCtx(fantomObj, ctx)
	}

	override Obj? fromBsonVal(Obj? bsonVal, Type? fantomType) {
		if (fantomType == null) return null	// this null is just convenience to allow [args].map { it?.typeof }
		ctx := BsonConverterCtx.makeTop(this, fantomType, bsonVal, options)
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

	override BsonConverter get(Type type) {
		// if a specific converter can't be found then embed a record
		typeLookup.findParent(type)
	}
	
	static Type:BsonConverter _defConvs() {
		config				:= Type:BsonConverter[:]
		bsonLiteral			:= BsonLiteralConverter()

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
		config[Obj#]		= BsonObjConverter()
		config[Map#]		= BsonMapConverter()
		config[List#]		= BsonListConverter()

		// Fantom Literals
		config[Date#]		= BsonDateConverter()
		config[Decimal#]	= BsonSimpleConverter(Decimal#)
		config[Depend#]		= BsonSimpleConverter(Depend#)
		config[Duration#]	= BsonSimpleConverter(Duration#)
		config[Enum#]		= BsonEnumConverter()
		config[Locale#]		= BsonSimpleConverter(Locale#)
		config[MimeType#]	= BsonSimpleConverter(MimeType#)
		config[Range#]		= BsonSimpleConverter(Range#)
		config[Slot#]		= BsonSlotConverter()
		config[Time#]		= BsonSimpleConverter(Time#)
		config[TimeZone#]	= BsonSimpleConverter(TimeZone#)
		config[Type#]		= BsonTypeConverter()
		config[Unit#]		= BsonSimpleConverter(Unit#)
		config[Uri#]		= BsonSimpleConverter(Uri#)
		config[Uuid#]		= BsonSimpleConverter(Uuid#)
		config[Version#]	= BsonSimpleConverter(Version#)
		
		return config
	}
}
