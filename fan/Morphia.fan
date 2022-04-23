using afMongo::MongoConnMgr
using afMongo::MongoConnMgrPool
using afMongo::MongoConnUrl
using afBson::BsonIO

class Morphia {
	
	** The underlying connection manager.
	const MongoConnMgr	connMgr
	
	** The Object-Relational-Mapping converters.
	const BsonConvs	bsonConvs

	** The name of the database.
	const Str dbName
	
	** Creates a new Morphia instance.
	new make(Uri connectionUrl, BsonConvs? bsonConvs := null, Log? log := null) {
		this.connMgr	= MongoConnMgrPool(connectionUrl, log)	
		this.dbName		= MongoConnUrl(connectionUrl).database
		this.bsonConvs	= bsonConvs ?: BsonConvs()
	}
	
	** Creates a new 'Datastore' instance for the given entity type.
	Datastore datastore(Type entityType) {
		DatastoreImpl(connMgr, bsonConvs, dbName, entityType)
	}
	
	** Converts the given Fantom object to its BSON object representation.
	[Str:Obj?]? toBsonDoc(Obj? fantomObj) {
		bsonConvs.toBsonDoc(fantomObj)
	}
	
	** Converts a BSON object to the given Fantom type.
	Obj? fromBsonDoc([Str:Obj?]? bsonObj, Type? fantomType) {
		bsonConvs.fromBsonDoc(bsonObj, fantomType)
	}
	
	**
	Str prettyPrint(Obj? entity, Int? maxWidth := null, Str? indent := null) {
		BsonIO().print(bsonConvs.toBsonVal(entity), maxWidth, indent)
	}
}
