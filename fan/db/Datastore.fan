using afBeanUtils::ReflectUtils
using afMongo::MongoConnMgr
using afMongo::MongoColl
using afMongo::MongoCmd
using afMongo::MongoDb
using afMongo::MongoQ

** (Service) -
** Wraps a MongoDB [Collection]`afMongo::MongoColl`, converting Fantom entities to / from BSON documents.
**
** When injecting as a service, use the '@Inject.type' attribute to state the Entity type:
**
**   syntax: fantom
**
**   @Inject { type=MyEntity# }
**   private const Datastore myEntityDatastore
**
** You can also autobuild a Datastore instance by passing in the entity type as a ctor param:
**
**   syntax: fantom
**
**   scope.build(Datastore#, [MyEntity#])
const mixin Datastore {
	
	** The underlying MongoDB collection this Datastore wraps.
	abstract MongoColl collection()

	** The Fantom entity type this Datastore associates with.
	abstract Type	type()

	** Create a new Datastore instance.
	static new make(MongoConnMgr connMgr, Type entityType, BsonConvs? bsonConvs := null, Str? dbName := null) {
		DatastoreImpl(connMgr, entityType, bsonConvs, dbName)
	}

	

	// ---- Collection ----------------------------------------------------------------------------

	** Returns 'true' if the underlying MongoDB collection exists.
	abstract Bool exists()

	** Returns 'true' if the collection has no documents.
	**
	** Convenience for 'datastore.exists && datastore.size == 0'.
	abstract Bool isEmpty()

	** Drops the underlying MongoDB collection.
	**
	** Note that deleting all documents is MUCH quicker than dropping the Collection. See `deleteAll` for details.
	abstract This drop(Bool force := false)
	
	
	
	// ---- Cursor Queries ------------------------------------------------------------------------

	** A general purpose 'find()' method whose cursor returns converted entity objects.
	** 
	** pre>
	** syntax: fantom
	** find(["rick":"morty"]) {
	**   it->sort        = ["fieldName":1]
	**   it->hint        = "_indexName_"
	**   it->skip        = 50
	**   it->limit       = 100
	**   it->projection  = ["_id":1, "name":1]
	**   it->batchSize   = 101
	**   it->singleBatch = true
	**   it->collation   = [...]
	** }.toList
	** <pre
	** 
	** The given query may generated from 'query()'.
	abstract MorphiaCur find([Str:Obj?]? query := null, |MongoCmd cmd|? optsFn := null)

	** An (optimised) method to return one document from the given 'query'.
	**
	** Throws an 'Err' if no documents are found and 'checked' is 'true'.
	** Always throws an 'Err' if the query returns more than one document.
	abstract Obj? findOne(Bool checked, |MongoQ| queryFn)

	** Returns a list of entities that match the given 'query'.
	**
	** If 'sort' is a Str it should the name of an index to use as a hint.
	**
	** If 'sort' is a '[Str:Obj?]' map, it should be a sort document with field names as keys.
	** Values may either be the standard Mongo '1' and '-1' for ascending / descending.
	**
	** The 'sort' map, should it contain more than 1 entry, must be ordered.
	abstract Obj[] findAll(Obj? sort := null, |MongoQ|? queryFn := null)

	** Returns the number of documents that would be returned by the given 'query'.
	**
	** Note: This method requires you to be familiar with Mongo query notation. If not, use the `Query` builder instead.
	abstract Int count(|MongoQ| queryFn)

	** Returns the document with the given Id.
	** Convenience / shorthand notation for 'findOne(["_id": id], checked)'
	@Operator
	abstract Obj? get(Obj? id, Bool checked := true)
	
	

	// ---- Write Operations ----------------------------------------------------------------------

	** Inserts the given entity.
	** Returns the entity.
	abstract Obj insert(Obj entity)

	** Deletes the given entity from the MongoDB.
	** Throws an 'Err' if 'checked' and nothing was deleted.
	abstract Void delete(Obj entity, Bool checked := true)

	** Deletes entity with the given Id.
	** Throws an 'Err' if 'checked' and nothing was deleted.
	abstract Void deleteById(Obj id, Bool checked := true)

	** Deletes all entities in the Datastore. Returns the number of entities deleted.
	** 
	** Note this is MUCH quicker than dropping the Collection.
	abstract Int deleteAll()
	
	** Updates the given entity.
	** Throws an 'Err' if 'checked' and nothing was updated.
	**
	** Will always throw 'OptimisticLockErr' if the entity contains a '_version' field which does not match what's in the
	** database. On a successful save, this will increment the '_version' field on the entity.
	abstract Void update(Obj entity, Bool checked := true)

	
	
	// ---- Aggregation Commands ------------------------------------------------------------------

	** Returns the number of documents in the collection.
	abstract Int size()

	
	
	// ---- Conversion Methods --------------------------------------------------------------------
	
	** Returns a 'MongoQ' that accepts fields as keys, and converts all values to BSON.
	abstract MongoQ query()
	
	** Converts the Mongo document to an entity instance.
	**
	** The returned object is not guaranteed to be of any particular object,
	** for this is just a convenience for calling 'Converters.toFantom(...)'.
	abstract Obj? fromBsonDoc([Str:Obj?]? mongoDoc)

	** Converts the entity instance to a Mongo document.
	**
	** Convenience for calling 'Converters.toMongo(...)'.
	abstract [Str:Obj?]? toBsonDoc(Obj? entity)

	** For internal use only. Use 'Converters' service instead.
	@NoDoc
	abstract Obj? toBson(Obj? entity)
}

internal const class DatastoreImpl : Datastore {

	override const MongoColl	collection
	override const Type			type

	private const BsonConvs		bsonConvs
	private const Field 		idField
	private const Field? 		versionField
	private const Func			valueHookFn

	internal new make(MongoConnMgr connMgr, Type type, BsonConvs? bsonConvs, Str? dbName) {
		bsonConvs	 = bsonConvs ?: BsonConvs()
		entity		:= (Entity?) type.facet(Entity#, false)
		collName	:= entity?.name ?: type.name
		props		:= bsonConvs.propertyCache.getOrFindProps(type)

		this.bsonConvs		= bsonConvs 
		this.collection		= MongoColl(connMgr, collName, dbName)
		this.type			= type
		this.idField		= props.find { it.name == "_id" 	 }?.field ?: throw Err("Could not find BSON property named '_id' on ${type.qname}")
		this.versionField	= props.find { it.name == "_version" }?.field
		this.valueHookFn	= #toBson.func.bind([this])

		if (versionField != null && !versionField.type.fits(Int#))
			throw Err(stripSys("_version field must be of type Int - ${versionField.qname} -> ${versionField.type.qname}"))
	}

	
	
	// ---- Collection ----------------------------------------------------------------------------

	override Bool exists() {
		collection.exists
	}

	override Bool isEmpty() {
		exists && size == 0
	}

	override This drop(Bool force := false) {
		collection.drop(force)
		return this
	}



	// ---- Cursor Queries ------------------------------------------------------------------------

	override MorphiaCur find([Str:Obj?]? query := null, |MongoCmd cmd|? optsFn := null) {
		mongoCur := collection.find(query, optsFn)
		return MorphiaCur(mongoCur, type, bsonConvs)
	}
	
	override Obj? findOne(Bool checked, |MongoQ| queryFn) {
		query := this.query
		queryFn.call(query)
		entity := collection.findOne(query.query, checked)
		return (entity == null) ? null : fromBsonDoc(entity)
	}

	override Obj[] findAll(Obj? sort := null, |MongoQ|? queryFn := null) {
		query := this.query
		queryFn?.call(query)
		return find(query.query) {
			if (sort is Str) it->hint = sort
			if (sort is Map) it->sort = sort
		}.toList
	}

	override Int count(|MongoQ| queryFn) {
		query := this.query
		queryFn.call(query)
		return collection.count(query.query)
	}

	@Operator
	override Obj? get(Obj? id, Bool checked := true) {
		if (id != null && !ReflectUtils.fits(id.typeof, idField.type))
			throw ArgErr(stripSys("ID does not fit ${idField.qname} ${idField.type.signature}# - ${id.typeof.signature} ${id}"))
		mongId := toBson(id)
		entity := collection.get(mongId, checked)
		return fromBsonDoc(entity)
	}

	
	
	// ---- Write Operations ----------------------------------------------------------------------

	override Obj insert(Obj entity) {
		if (!entity.typeof.fits(type))
			throw ArgErr("Entity of type ${entity.typeof.qname} does not fit Datastore type ${type.qname}")
		collection.insert(toBsonDoc(entity))
		return entity
	}

	override Void delete(Obj entity, Bool checked := true) {
		if (!entity.typeof.fits(type))
			throw ArgErr("Entity of type ${entity.typeof.qname} does not fit Datastore type ${type.qname}")
		id := idField.get(entity)
		deleteById(id, checked)
	}

	override Void deleteById(Obj id, Bool checked := true) {
		if (!ReflectUtils.fits(id.typeof, idField.type))
			throw ArgErr(stripSys("ID does not fit ${idField.qname} ${idField.type.signature}# - ${id.typeof.signature} ${id}"))
		mongId := toBson(id)
		n := collection.delete(["_id" : mongId])
		if (checked && n == 0)
			throw Err("Could not find Morphia entity ${type.qname} with ID: ${id}")
	}
	
	override Int deleteAll() {
		collection.deleteAll
	}

	override Void update(Obj entity, Bool checked := true) {
		if (!entity.typeof.fits(type))
			throw ArgErr("Entity of type ${entity.typeof.qname} does not fit Datastore type ${type.qname}")
		id		:= idField.get(entity)
		mongId	:= toBson(id)

		if (versionField == null) {
			result := collection.replace(["_id" : mongId], toBsonDoc(entity))
			noOfMatches := result["n"]
			if (noOfMatches == 0 && checked)
				throw Err("Could not find Morphia entity ${type.qname} with ID: ${mongId}")

		} else {
			// don't user $inc & $set because then we have to $unset all the null fields!
			version	:= (Int) versionField.get(entity)
			toMongo := toBsonDoc(entity).set("_version", version + 1)
			result	:= collection.replace(["_id" : mongId, "_version" : version], toMongo)
			noOfMatches := result["n"]

			if (noOfMatches == 0) {
				// determine which err we're gonna throw, if any
				// always throw an optimistic locking err - that's what the _version is for!
				// to 'force' a save, drop down to Mongo collections.
				if (collection.get(mongId, false) != null)
					throw OptimisticLockErr("A newer version of ${type.qname} already exists, with ID ${mongId}", type, version)
				if (checked)
					throw Err("Could not find Morphia entity ${type.qname} with ID: ${mongId}")
				return
			}

			// if all okay, attempt to inc the _version in the entity
			if (!versionField.isConst)
				versionField.set(entity, version+1)
		}
	}
	
	

	// ---- Aggregation Commands ------------------------------------------------------------------

	override Int size() {
		collection.size
	}
	
	

	// ---- Conversion Methods --------------------------------------------------------------------

	override Obj? fromBsonDoc([Str:Obj?]? doc) {
		bsonConvs.fromBsonDoc(doc, type)
	}

	override [Str:Obj?]? toBsonDoc(Obj? entity) {
		bsonConvs.toBsonDoc(entity)
	}

	override Obj? toBson(Obj? value) {
		bsonConvs.toBsonVal(value, value?.typeof)
	}
	
	override MongoQ query() {
		MongoQ(#nameHook.func, valueHookFn)
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

	
	
	// ---- Helper Methods ------------------------------------------------------------------------

	override Str toStr() {
		"MongoDB Datastore for ${type.qname}"
	}

	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
