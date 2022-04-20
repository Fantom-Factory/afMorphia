using afBeanUtils::BeanBuilder

** (Service) - 
** Converts Fantom objects to and from their JSON representation.
const mixin BsonConverters {

	** Returns a new 'BsonConverters' instance.
	** 
	** If 'converters' is 'null' then 'defConvs' is used. Common options are:
	** 
	**   afBson.makeEntity        : |Type type, Field:Obj? fieldVals->Obj?| { BeanBuilder.build(type, vals) }
	**   afBson.strictMode        : false
	**   afBson.dateFormat        : "YYYY-MM-DD"
	**   afBson.dateTimeFormat    : "YYYY-MM-DD'T'hh:mm:ss.FFFz"
	**   afBson.propertyCache     : BsonPropertyCache()
	**   afBson.serializableMode  : true
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
}

internal const class BsonConvertersImpl : BsonConverters {
	const BsonTypeLookup	typeLookup
	const BsonPropertyCache	propertyCache
	const Unsafe			optionsRef	// use Unsafe because JS can't handle immutable functions

	new make(|This| f) { f(this) }
	
	new makeArgs(Type:BsonConverter converters, [Str:Obj?]? options) {
		serializableMode := options?.get("afBson.serializableMode", false) == true
		this.typeLookup = BsonTypeLookup(converters)
		this.optionsRef	= Unsafe(Str:Obj?[
			"afBson.makeEntity"		: |Type type, Field:Obj? vals->Obj?| { BeanBuilder.build(type, vals) },
			"afBson.makeBsonObj"	: |-> Str:Obj?| { Str:Obj?[:] { ordered = true } },
			"afBson.makeMap"		: |Type t->Map| { Map((t.isGeneric ? Obj:Obj?# : t).toNonNullable) { it.ordered = true } },
			"afBson.strictMode"		: false,
			"afBson.propertyCache"	: BsonPropertyCache(serializableMode),
		])
		
		if (options != null)
			this.optionsRef = Unsafe(this.options.rw.setAll(options))

		if (Env.cur.runtime != "js")
			// JS can't handle immutable functions, but I'd still like them to be thread safe in Java
			optionsRef = Unsafe(optionsRef.val.toImmutable)
		
		this.propertyCache	= this.options["afBson.propertyCache"]
	}

	Str:Obj? options() { optionsRef.val }
	
	override BsonConverters withOptions(Str:Obj? newOptions) {
		if (newOptions.containsKey("afBson.serializableMode")) {
			serializableMode := newOptions.get("afBson.serializableMode", false) == true
			newOptions["afBson.propertyCache"] = BsonPropertyCache(serializableMode)
		}
		return BsonConvertersImpl {
			it.optionsRef		= Unsafe(this.options.rw.setAll(newOptions))
			it.propertyCache	= it.options["afBson.propertyCache"] ?: this.propertyCache
			it.typeLookup		= this.typeLookup
		}
	}
	
	override Obj? _toBsonCtx(Obj? fantomObj, BsonConverterCtx ctx) {
		hookVal := ctx.fnToBsonHook(fantomObj)		
		return get(ctx.type).toBsonVal(fantomObj, ctx)
	}

	override Obj? _fromBsonCtx(Obj? bsonVal, BsonConverterCtx ctx) {
		hookVal := ctx.fnFromBsonHook(bsonVal)
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

	override BsonConverter get(Type type) {
		// if a specific converter can't be found then embed a record
		typeLookup.findParent(type)
	}
	
	static Type:BsonConverter _defConvs() {
		config				:= Type:BsonConverter[:]
		bsonLiteral			:= BsonLiteralConverter()
		numLiteral			:= BsonNumConverter()

		// JSON Literals - https://bson.org/
		config[Bool#]		= bsonLiteral
		config[Float#]		= numLiteral
		config[Decimal#]	= numLiteral
		config[Int#]		= numLiteral
		config[Num#]		= numLiteral
		config[Str#]		= bsonLiteral
		
		// Containers
		config[Obj#]		= BsonObjConverter()
		config[Map#]		= BsonMapConverter()
		config[List#]		= BsonListConverter()

		// Fantom Literals
		config[Date#]		= BsonDateConverter()
		config[DateTime#]	= BsonDateTimeConverter()
		config[Depend#]		= BsonSimpleConverter(Depend#)
		config[Duration#]	= BsonSimpleConverter(Duration#)
		config[Enum#]		= BsonEnumConverter()
		config[Locale#]		= BsonSimpleConverter(Locale#)
		config[MimeType#]	= BsonSimpleConverter(MimeType#)
		config[Range#]		= BsonSimpleConverter(Range#)
		config[Regex#]		= BsonSimpleConverter(Regex#)
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
