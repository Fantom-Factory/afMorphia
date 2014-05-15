using afIoc
using afIocConfig
using afBson
using afMongo
using inet
using concurrent

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class MorphiaModule {

	static Void bind(ServiceBinder binder) {
		binder.bind(Morphia#)
		binder.bind(Converters#).withoutProxy
	}
	
	@Build
	static ConnectionManager buildConnectionManager(IocConfigSource iocConfig, ActorPools actorPools) {
		// TODO: check for mongodb scheme in url
		mongoUrl  := (Uri) iocConfig.get(MorphiaConfigIds.mongoUrl, Uri#)
		actorPool := actorPools.get("afMorphia.connectionManager")
		return ConnectionManagerPooled(actorPool , IpAddr(mongoUrl.host), mongoUrl.port)
	}
	
	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(MappedConfig config) {
		config["afMorphia.connectionManager"] = ActorPool() { it.maxThreads = 1 }
	}

	@Contribute { serviceType=Converters# }
	static Void contributeConverters(MappedConfig config) {		
		mongoLiteral		:= config.autobuild(LiteralConverter#)
		
		// Mongo Literals
		config[Bool#]		= mongoLiteral
		config[Binary#]		= mongoLiteral
		config[Buf#]		= mongoLiteral
		config[Code#]		= mongoLiteral
		config[DateTime#]	= mongoLiteral
		config[Float#]		= mongoLiteral
		config[Int#]		= mongoLiteral
		config[MaxKey#]		= mongoLiteral
		config[MinKey#]		= mongoLiteral
		config[ObjectId#]	= mongoLiteral
		config[Regex#]		= mongoLiteral
		config[Str#]		= mongoLiteral
		config[Timestamp#]	= mongoLiteral
		
		// Containers
		config[List#]		= config.createProxy(Converter#, ListConverter#, [true])
		config[Map#]		= config.createProxy(Converter#, MapConverter#, [true])

		// Fantom Literals
		config[Date#]		= DateConverter()
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
		config[MorphiaConfigIds.mongoUrl]			= `mongodb://localhost:27017`
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig config, Registry registry, Morphia morphia) {
		config.add |->| { 
			registry.callMethod(Morphia#onStartup, morphia)
		}
	}
}
