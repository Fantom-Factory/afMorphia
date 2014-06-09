using afIoc
using afIocConfig
using afMongo

** (Service) - 
** The main entry point into 'Morphia'.
const class Morphia {

	** The MongoDB database this 'Morphia' instance wraps. 
	** By default the database is taken from the [MongoUrl]`MorphiaConfigIds.mongoUrl`. 
	const Database	database
	
	@Inject private const Converters	converters
	@Inject private const Registry 		registry

	** Having 'database' as a ctor param allows Morphia instances to be created for any database, 
	** not just the default.
	private new make(Database database, |This|in) {
		in(this)
		this.database = database
	}

	** Convenience / shorthand notation for 'datastore(entityType, database)'
	@Operator
	Datastore get(Type entityType, Database? database := null) {
		datastore(entityType, database)
	}
	
	** Returns a 'Datastore' instance for the given entity type.
	** 
	** If 'database' is null, the default database from the Mongo connection url is used.
	Datastore datastore(Type entityType, Database? database := null) {
		registry.autobuild(Datastore#, [entityType, database ?: this.database])
	}
	
	** Converts the given Mongo document to a Fantom entity instance.
	Obj fromMongoDoc(Type entityType, Str:Obj? mongoDoc) {
		converters.toFantom(entityType, mongoDoc)
	}
	
	** Converts the given entity instance to a Mongo document.
	Str:Obj? toMongoDoc(Obj entity) {
		converters.toMongo(entity)		
	}
}
