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
		binder.bind(Converters#).withoutProxy
	}
	
	@Build
	static ConnectionManager buildConnectionManager(IocConfigSource iocConfig, ActorPools actorPools) {
		mongoUri  := (Uri) iocConfig.get(MorphiaConfigIds.mongoUrl, Uri#)
		actorPool := actorPools.get("afMorphia.connectionManager")
		return ConnectionManagerPooled(actorPool , mongoUri)
	}
	
	@Build
	static Database buildDatabase(IocConfigSource iocConfig, ConnectionManager conMgr) {
		mongoUri	:= (Uri) iocConfig.get(MorphiaConfigIds.mongoUrl, Uri#)
		dbName		:= mongoUri.path.join("/")	// this gets rid of any leading slashes - not that there *should* be anything to join!
		return Database(conMgr, dbName)
	}
	
	// TODO: IoC-1.6.2
	@Contribute { serviceType=DependencyProviderSource# }
	static Void contributeDependencyProviders(OrderedConfig config) {
		config.add(config.createProxy(DependencyProvider#, DatastoreDependencyProvider#))
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
	internal static Void contributeRegistryStartup(OrderedConfig config, ConnectionManager conMgr) {
		config.add |->| {
			// print that logo! Oh, and check that DB version while you're at it!
			mc := MongoClient(conMgr)
		}
	}

	@Contribute { serviceType=RegistryShutdownHub# }
	internal static Void contributeRegistryShutdown(OrderedConfig config, ConnectionManager conMgr) {
		config.add |->| {
			conMgr.shutdown
		}
	}
}
