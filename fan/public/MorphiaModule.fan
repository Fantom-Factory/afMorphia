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

	static Void defineServices(ServiceDefinitions defs) {
		defs.add(Morphia#)
		defs.add(Converters#)
		defs.add(IntSequences#)
	}
	
	@Build { serviceId="afMongo::ConnectionManager" }
	static ConnectionManager buildConnectionManager(ConfigSource configSrc, ActorPools actorPools) {
		mongoUri  := (Uri) configSrc.get(MorphiaConfigIds.mongoUrl, Uri#)
		actorPool := actorPools.get("afMorphia.connectionManager")
		return ConnectionManagerPooled(actorPool , mongoUri)
	}

	@Build { serviceId="afMongo::Database" }
	static Database buildDatabase(ConfigSource configSrc, ConnectionManager conMgr) {
		mongoUrl	:= (Uri) configSrc.get(MorphiaConfigIds.mongoUrl, Uri#)
		dbName		:= mongoUrl.path.join("/")	// this gets rid of any leading slashes - not that there *should* be anything to join!
		return Database(conMgr, dbName)
	}
	
	@Contribute { serviceType=DependencyProviders# }
	static Void contributeDependencyProviders(Configuration config) {
		config.set("afMorphia.datastoreProvider", config.autobuild(DatastoreProvider#)).before("afIoc.serviceProvider")
	}
	
	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(Configuration config) {
		config["afMorphia.connectionManager"] = ActorPool() { it.name = "afMorphia.connectionManager"; it.maxThreads = 1 }
	}

	@Contribute { serviceType=Converters# }
	static Void contributeConverters(Configuration config) {		
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
		config[Obj#]		= config.createProxy(Converter#, ObjConverter#, [false])
		config[Map#]		= config.createProxy(Converter#, MapConverter#)
		config[List#]		= config.createProxy(Converter#, ListConverter#)
		
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
	static Void contributeFactoryDefaults(Configuration config) {
		config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017`
		config[MorphiaConfigIds.intSequencesCollectionName] = "IntSequences"
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(Configuration config, ConnectionManager conMgr) {
		config["afMorphia.testConnection"] = |->| {
			// print that logo! Oh, and check that DB version while you're at it!
			mc := MongoClient(conMgr)
		}
	}

	@Contribute { serviceType=RegistryShutdown# }
	internal static Void contributeRegistryShutdown(Configuration config, ConnectionManager conMgr) {
		config["afMorphia.closeConnections"] = |->| {
			conMgr.shutdown
		}
	}
}
