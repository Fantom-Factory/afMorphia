using afIoc
using afIocConfig
using afMongo

** (Service) - 
** The main entry point into 'Morphia'.
const mixin Morphia {

	** The MongoDB database this 'Morphia' instance wraps. 
	** By default the database is taken from the [MongoUrl]`MorphiaConfigIds.mongoUrl`. 
	abstract Database	database()
	
	** Convenience / shorthand notation for 'datastore(entityType, database)'
	@Operator
	abstract Datastore get(Type entityType, Database? database := null)
	
	** Returns a 'Datastore' instance for the given entity type.
	** 
	** If 'database' is null, the default database from the Mongo connection url is used.
	abstract Datastore datastore(Type entityType, Database? database := null)
	
	** Converts the given Mongo document to a Fantom entity instance.
	abstract Obj fromMongoDoc(Type entityType, Str:Obj? mongoDoc)
	
	** Converts the given entity instance to a Mongo document.
	abstract Str:Obj? toMongoDoc(Obj entity)
}

internal const class MorphiaImpl : Morphia {

	override const Database	database
	
	@Inject private const Converters	converters
	@Inject private const Registry 		registry

	private new make(Database database, |This|in) {
		in(this)
		this.database = database
	}

	@Operator
	override Datastore get(Type entityType, Database? database := null) {
		datastore(entityType, database)
	}
	
	override Datastore datastore(Type entityType, Database? database := null) {
		registry.autobuild(Datastore#, [entityType, database ?: this.database])
	}
	
	override Obj fromMongoDoc(Type entityType, Str:Obj? mongoDoc) {
		converters.toFantom(entityType, mongoDoc)
	}
	
	override Str:Obj? toMongoDoc(Obj entity) {
		converters.toMongo(entity)		
	}
}
