using afMongo::MongoConnMgr
using afMongo::MongoConnUrl
using afMongo::MongoDb
using afMongo::MongoQ
using afMongo::MongoClient
using afBson::BsonIO

** (Service) -
** Mongo to Fantom Object Mapping.
const class Morphia {
	
	** The underlying connection manager.
	const MongoConnMgr	connMgr
	
	** The Object-Relational-Mapping converters.
	const BsonConvs	bsonConvs

	** The name of the database (if defined).
	const Str? dbName
	
	** The referenced database (if defined).
	const MongoDb? db
	
	** Creates a new Morphia instance.
	new make(Uri connectionUrl, BsonConvs? bsonConvs := null, Str? dbName := null, Log? log := null) {
		this.connMgr	= MongoConnMgr(connectionUrl, log).startup	
		this.bsonConvs	= bsonConvs ?: BsonConvs()
		this.dbName		= dbName ?: connMgr.database
		this.db			= this.dbName == null ? null : MongoDb(connMgr, this.dbName)
		// print the logo
		MongoClient(connMgr).toStr
	}
	
	@NoDoc
	new makeWithConnMgr(MongoConnMgr connMgr, BsonConvs? bsonConvs := null, Str? dbName := null) {
		this.connMgr	= connMgr.startup
		this.bsonConvs	= bsonConvs ?: BsonConvs()
		this.dbName		= dbName ?: connMgr.database
		this.db			= this.dbName == null ? null : MongoDb(connMgr, this.dbName)
		// given this is advanced us - no need for the logo
	}
	
	** Convenience / shorthand notation for 'datastore(name)'
	@Operator	
	Datastore get(Type entityType) {
		datastore(entityType)
	}

	** Creates a new 'Datastore' instance for the given entity type.
	Datastore datastore(Type entityType) {
		DatastoreImpl(entityType, connMgr, bsonConvs, dbName)
	}
	
	** Converts the given Fantom object to its BSON object representation.
	[Str:Obj?]? toBsonDoc(Obj? fantomObj) {
		bsonConvs.toBsonDoc(fantomObj)
	}
	
	** Converts a BSON object to the given Fantom type.
	Obj? fromBsonDoc([Str:Obj?]? bsonObj, Type? fantomType) {
		bsonConvs.fromBsonDoc(bsonObj, fantomType)
	}
	
	** Creates a 'MongoQ' instance that's adapted to query Morphia entities.
	MongoQ query() {
		MongoQ(#nameHook.func) { bsonConvs.toBsonVal(it) }
	} 
	
	** Converts the given entity / object to BSON and pretty prints it.
	Str prettyPrint(Obj? entity, Int? maxWidth := null, Str? indent := null) {
		BsonIO().print(bsonConvs.toBsonVal(entity), maxWidth, indent)
	}
	
	** Convenience for 'MongoConnMgr.shutdown()'.
	Void shutdown() {
		connMgr.shutdown
	}

	private static Str nameHook(Obj name) {
		fieldName := name as Str

		if (name is Field) {
			field := (Field) name
			// we can't check if the field belongs to an Entity (think nested objects)
			property := (BsonProp?) field.facet(BsonProp#, false)
			fieldName = property?.name ?: field.name
		}

		if (fieldName == null)
			throw ArgErr("Key must be a Field or Str: ${name.typeof.qname} - ${name}")
		
		return fieldName
	}
}
