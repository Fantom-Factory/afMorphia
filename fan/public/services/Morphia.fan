using afIoc
using afIocConfig
using afMongo

** (Service) - 
** The main entry point into 'Morphia'.
const class Morphia {

	@Config
	@Inject private const Uri				mongoUrl
	@Inject private const Registry 			registry
	@Inject private const ConnectionManager	conMgr
	
	@NoDoc
	new make(|This|in) { in(this) }

	Void onStartup() {
		// print that logo! Oh, and check the DB version!
		mc := MongoClient(conMgr)
	}

	@Operator
	Datastore get(Type entityType) {
		datastore(entityType)
	}
	
	Datastore datastore(Type entityType) {
		// TODO: type check entity
		
		db := Database(conMgr, mongoUrl.path.first)
		ds := registry.autobuild(Datastore#, [db, entityType])
		return ds
	}
}
