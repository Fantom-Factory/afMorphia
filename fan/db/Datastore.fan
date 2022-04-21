using afBeanUtils::NotFoundErr
using afBeanUtils::ReflectUtils
using afMongo::MongoColl
using afMongo::MongoDb

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

	** The qualified name of the MongoDB collection.
	** It takes the form of:
	**
	**   <database>.<collection>
	abstract Str qname()

	** The simple name of the MongoDB collection.
	abstract Str name()

	// ---- Collection ----------------------------------------------------------------------------

	** Returns 'true' if the underlying MongoDB collection exists.
	**
	** @see `afMongo::Collection.exists`
	abstract Bool exists()

	** Returns 'true' if the collection has no documents.
	**
	** Convenience for 'datastore.exists && datastore.size == 0'.
	abstract Bool isEmpty()

	** Drops the underlying MongoDB collection.
	**
	** Note that deleting all documents is MUCH quicker than dropping the Collection. See `deleteAll` for details.
	** 
	** @see `afMongo::Collection.drop`
	abstract This drop(Bool force := false)

	// ---- Cursor Queries ------------------------------------------------------------------------

	** An (optimised) method to return one document from the given 'query'.
	**
	** Note: This method requires you to be familiar with Mongo query notation. If not, use the `Query` builder instead.
	**
	** Throws 'MongoErr' if no documents are found and 'checked' is 'true', returns 'null' otherwise.
	** Always throws 'MongoErr' if the query returns more than one document.
	**
	** @see `afMongo::Collection.findOne`
	abstract Obj? findOne([Str:Obj?]? query := null, Bool checked := true)

	** Returns a list of entities that match the given 'query'.
	**
	** Note: This method requires you to be familiar with Mongo query notation. If not, use the `Query` builder instead.
	**
	** If 'sort' is a Str it should the name of an index to use as a hint.
	**
	** If 'sort' is a '[Str:Obj?]' map, it should be a sort document with field names as keys.
	** Values may either be the standard Mongo '1' and '-1' for ascending / descending or the
	** strings 'ASC' / 'DESC'.
	**
	** The 'sort' map, should it contain more than 1 entry, must be ordered.
	**
	** @see `afMongo::Collection.findAll`
	abstract Obj[] findAll([Str:Obj?]? query := null, Obj? sort := null, Int skip := 0, Int? limit := null, [Str:Obj?]? projection := null)

	** Returns the number of documents that would be returned by the given 'query'.
	**
	** Note: This method requires you to be familiar with Mongo query notation. If not, use the `Query` builder instead.
	**
	** @see `afMongo::Collection.findCount`
	abstract Int findCount([Str:Obj?]? query := null)

	** Returns the document with the given Id.
	** Convenience / shorthand notation for 'findOne(["_id": id], checked)'
	@Operator
	abstract Obj? get(Obj? id, Bool checked := true)

	// ---- Write Operations ----------------------------------------------------------------------

	** Inserts the given entity.
	** Returns the entity.
	**
	** @see `afMongo::Collection.insert`
	abstract Obj insert(Obj entity)

	** Deletes the given entity from the MongoDB.
	** Throws 'MorphiaErr' if 'checked' and nothing was deleted.
	**
	** @see `afMongo::Collection.delete`
	abstract Void delete(Obj entity, Bool checked := true)

	** Deletes entity with the given Id.
	** Throws 'MorphiaErr' if 'checked' and nothing was deleted.
	**
	** @see `afMongo::Collection.delete`
	abstract Void deleteById(Obj id, Bool checked := true)

	** Deletes all entities in the Datastore. Returns the number of entities deleted.
	** 
	** Note this is MUCH quicker than dropping the Collection.
	abstract Int deleteAll()
	
	** Updates the given entity.
	** Throws 'MorphiaErr' if 'checked' and nothing was updated.
	**
	** Will always throw 'OptimisticLockErr' if the entity contains a '_version' field which doesn't match what's in the
	** database. On a successful save, this will increment the '_version' field on the entity.
	**
	** @see `afMongo::Collection.update`
	abstract Void update(Obj entity, Bool checked := true)

	// ---- Aggregation Commands ------------------------------------------------------------------

	** Returns the number of documents in the collection.
	**
	** @see `afMongo::Collection.size`
	abstract Int size()

	// ---- Conversion Methods --------------------------------------------------------------------

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
	override const Str			qname
	override const Str			name

	private const BsonConverters	converters
	private const Field 		idField
	private const Field? 		versionField

	// database is an injected service
	internal new make(Type type, MongoDb database, BsonConverters converters) {
		entity		:= (Entity?) type.facet(Entity#, false)
		collName	:= entity?.name ?: type.name
		props		:= converters.propertyCache.getOrFindProps(type)

		this.converters		= converters
		this.collection		= database.collection(collName)
		this.type			= type
		this.qname			= collection.qname
		this.name			= collection.name
		this.idField		= props.find { it.name == "_id" 	 }?.field ?: throw IdNotFoundErr("Could not find property named '_id' on ${type.qname}.", props.map { it.name })
		this.versionField	= props.find { it.name == "_version" }?.field

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

	override Obj? findOne([Str:Obj?]? query := null, Bool checked := true) {
		entity := collection.findOne(query, checked)
		return (entity == null) ? null : fromBsonDoc(entity)
	}

	override Obj[] findAll([Str:Obj?]? query := null, Obj? sort := null, Int skip := 0, Int? limit := null, [Str:Obj?]? projection := null) {
		// ensure empty lists are correctly typed
		list := List.make(type, 16)
		collection.find(query) {
			it->sort		= sort
			// FIXME
//			if (sort is Str)	cursor.hint 	= sort
//			if (sort is Map)	cursor.orderBy  = sort
//			it->hint		= hint
			it->skip		= skip
			it->limit		= limit
			it->projection	= projection
		}.each |doc| {
			list.add(fromBsonDoc(doc))
		}
		return list
	}

	override Int findCount([Str:Obj?]? query := null) {
		collection.count(query)
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
		if (checked && n != 1)
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
			result := collection.update(["_id" : mongId], toBsonDoc(entity))
			noOfMatches := result["n"]
			if (noOfMatches == 0 && checked)
				throw Err("Could not find Morphia entity ${type.qname} with ID: ${mongId}")

		} else {
			// don't user $inc & $set because then we have to $unset all the null fields!
			version	:= (Int) versionField.get(entity)
			toMongo := toBsonDoc(entity).set("_version", version + 1)
			result	:= collection.update(["_id" : mongId, "_version" : version], toMongo)
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
		converters.fromBsonDoc(doc, type)
	}

	override [Str:Obj?]? toBsonDoc(Obj? entity) {
		converters.toBsonDoc(entity)
	}

	override Obj? toBson(Obj? entity) {
		converters.toBsonVal(entity, entity?.typeof)
	}

	// ---- Helper Methods ------------------------------------------------------------------------

	override Str toStr() {
		"MongoDB Datastore for ${type.qname}"
	}

	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}

@NoDoc
const class IdNotFoundErr : Err, NotFoundErr {
	override const Str?[] availableValues

	new make(Str msg, Obj?[] availableValues, Err? cause := null) : super(msg, cause) {
		this.availableValues = availableValues.map { it?.toStr }.sort
	}

	override Str toStr() {
		NotFoundErr.super.toStr
	}
}
