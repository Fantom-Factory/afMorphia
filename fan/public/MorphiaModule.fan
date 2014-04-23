using afIoc
using afIocConfig
using afBson

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
const class MorphiaModule {

	static Void bind(ServiceBinder binder) {
		binder.bind(Morphia#)
		binder.bind(Converters#).withoutProxy
	}
	
	@Contribute { serviceType=Converters# }
	static Void contributeConverters(MappedConfig config) {		
		mongoLiteral		:= config.autobuild(LiteralConverter#)
		
		// Mongo Literals
		config[Bool#]		= mongoLiteral
		config[Binary#]		= mongoLiteral
		config[Buf#]		= mongoLiteral
		config[Code#]		= mongoLiteral
		config[Date#]		= mongoLiteral
		config[DateTime#]	= mongoLiteral
		config[Float#]		= mongoLiteral
		config[Int#]		= mongoLiteral
		config[MaxKey#]		= mongoLiteral
		config[MinKey#]		= mongoLiteral
		config[ObjectId#]	= mongoLiteral
		config[Regex#]		= mongoLiteral
		config[Str#]		= mongoLiteral
		config[Timestamp#]	= mongoLiteral
		
		config[List#]		= config.createProxy(Converter#, ListConverter#, [true])
		config[Map#]		= config.createProxy(Converter#, MapConverter#, [true])

		// Fantom Literals
		config[Decimal#]	= DecimalConverter()
		config[Duration#]	= DurationConverter()
		config[Enum#]		= EnumConverter()
		config[Range#]		= RangeConverter()
		config[Slot#]		= SlotConverter()
		config[Type#]		= TypeConverter()
		config[Uri#]		= UriConverter()
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[MorphiaConfigIds.documentConverter]	= config.createProxy(Converter#, DocumentConverter#, [false])
	}
}
