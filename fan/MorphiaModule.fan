using afIoc
using afIocConfig
using afBson
using afMongo
using afConcurrent
using concurrent::Actor
using concurrent::ActorPool

** The [IoC]`pod:afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class MorphiaModule {

	static Void defineServices(RegistryBuilder defs) {
		defs.addService(Morphia#)
		defs.addService(Converters#)
		defs.addService(IntSequences#)
	}
	
	@Build { serviceId="afMongo::ConnectionManager" }
	static ConnectionManager buildConnectionManager(ConfigSource configSrc, ActorPools actorPools) {
		mongoUri  := (Uri) configSrc.get(MorphiaConfigIds.mongoUrl, Uri#)
		actorPool := actorPools.get("afMorphia.connectionManager")
		conMgr	  := ConnectionManagerPooled(actorPool , mongoUri)
		// if we startup here, then is saves everyone pissing about trying to order their registry
		// startup contributions to be *after* "afMorphia.conMgrStartup" or similar.
		conMgr.startup
		return conMgr
	}

	@Build { serviceId="afMongo::Database" }
	static Database buildDatabase(ConfigSource configSrc, ConnectionManager conMgr) {
		mongoUrl	:= (Uri) configSrc.get(MorphiaConfigIds.mongoUrl, Uri#)
		dbName		:= mongoUrl.path.join("/")	// this gets rid of any leading slashes - not that there *should* be anything to join!
		return Database(conMgr, dbName)
	}
	
	@Contribute { serviceType=DependencyProviders# }
	static Void contributeDependencyProviders(Configuration config) {
		config.set("afMorphia.datastoreProvider",  config.build( DatastoreProvider#)).before("afIoc.service")
		config.set("afMorphia.collectionProvider", config.build(CollectionProvider#)).before("afIoc.service")
	}
	
	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(Configuration config) {
		config["afMorphia.connectionManager"] = ActorPool() { it.name = "afMorphia.connectionManager"; it.maxThreads = 1 }
	}

	@Contribute { serviceType=Converters# }
	static Void contributeConverters(Configuration config) {		
		mongoLiteral		:= config.build(LiteralConverter#)
		
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
		config[Obj#]		= config.build(ObjConverter#, [false])
		config[Map#]		= config.build(MapConverter#)
		config[List#]		= config.build(ListConverter#)
		
		// Fantom Literals
		config[Date#]		= DateConverter()
		config[Depend#]		= SimpleConverter(Depend#)
		config[Decimal#]	= SimpleConverter(Decimal#)
		config[Duration#]	= SimpleConverter(Duration#)
		config[Enum#]		= EnumConverter()
		config[Locale#]		= SimpleConverter(Locale#)
		config[MimeType#]	= SimpleConverter(MimeType#)
		config[Range#]		= SimpleConverter(Range#)
		config[Slot#]		= SlotConverter()
		config[Time#]		= SimpleConverter(Time#)
		config[TimeZone#]	= SimpleConverter(TimeZone#)
		config[Type#]		= TypeConverter()
		config[Unit#]		= SimpleConverter(Unit#)
		config[Uri#]		= SimpleConverter(Uri#)
		config[Uuid#]		= SimpleConverter(Uuid#)
		config[Version#]	= SimpleConverter(Version#)
	}
	
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(Configuration config) {
		config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017`
		config[MorphiaConfigIds.intSequencesCollectionName] = "IntSequences"
	}
	
	internal static Void onRegistryStartup(Configuration config, ConnectionManager conMgr) {
		config["afMorphia.testConnection"] = |->| {
			// print that logo! Oh, and check that DB version while you're at it!
			mc := MongoClient(conMgr)
		}
	}

	internal static Void onRegistryShutdown(Configuration config, ConnectionManager conMgr) {
		config["afMorphia.closeConnections"] = |->| {
			conMgr.shutdown
		}
	}
}
