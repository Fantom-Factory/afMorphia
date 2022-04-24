using afMongo::MongoConnMgr
using afMongo::MongoConnUrl
using afMongo::MongoQ
using afBson::BsonIO

class Morphia {
	
	** The underlying connection manager.
	const MongoConnMgr	connMgr
	
	** The Object-Relational-Mapping converters.
	const BsonConvs	bsonConvs

	** The name of the database.
	const Str dbName
	
	** Creates a new Morphia instance.
	new make(Uri connectionUrl, BsonConvs? bsonConvs := null, Str? dbName := null, Log? log := null) {
		this.connMgr	= MongoConnMgr(connectionUrl, log)	
		this.bsonConvs	= bsonConvs ?: BsonConvs()
		this.dbName		= dbName ?: connMgr.database
	}
	
	** Creates a new 'Datastore' instance for the given entity type.
	Datastore datastore(Type entityType) {
		DatastoreImpl(connMgr, entityType, bsonConvs, dbName)
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
