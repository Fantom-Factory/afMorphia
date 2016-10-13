using afBeanUtils::NotFoundErr
using afBeanUtils::ReflectUtils
using afIoc
using afMongo

** (Service) -
** Wraps a MongoDB [Collection]`afMongo::Collection`, converting Fantom entities to / from Mongo documents.
** 
** When injecting as a service, use the '@Inject.type' attribute to state which Entity type it is for: 
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
	abstract Collection collection()

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

	** Updates the given entity.
	** Throws 'MorphiaErr' if 'checked' and nothing was updated. 
	** 
	** @see `afMongo::Collection.update`
	abstract Void update(Obj entity, Bool? upsert := false, Bool checked := true)

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
	abstract Obj fromMongoDoc(Str:Obj? mongoDoc)
	
	** Converts the entity instance to a Mongo document.
	** 
	** Convenience for calling 'Converters.toMongo(...)'.
	abstract Str:Obj? toMongoDoc(Obj entity)

	// ---- Query Methods -------------------------------------------------------------------------
	
	** Use to execute the given query.
	abstract QueryExecutor query(Query? query := null)

}

internal const class DatastoreImpl : Datastore {
	
	override const Collection	collection
	override const Type			type
	override const Str			qname
	override const Str			name
	
	@Inject
	private const Converters	converters
	private const Field 		idField
	
	internal new make(Type type, Database database, |This|in) {
		in(this)

		this.collection	= Collection(database, Utils.entityName(type))
		this.type		= verifyEntityType(type)
		this.qname		= collection.qname
		this.name		= collection.name
		this.idField	= type.fields.findAll { it.hasFacet(Property#) }.find |field->Bool| {
			property := (Property) field.facet(Property#)
			return field.name == "_id" || property.name == "_id"
		} ?: throw IdNotFoundErr(ErrMsgs.datastore_idFieldNotFound(type), propertyNames(type))

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
		return (entity == null) ? null : fromMongoDoc(entity)
	}

	override Obj[] findAll([Str:Obj?]? query := null, Obj? sort := null, Int skip := 0, Int? limit := null, [Str:Obj?]? projection := null) {
		all := collection.findAll(query, sort, skip, limit, projection)
		// ensure empty lists are correctly typed
		list := List.make(type, all.size)
		all.each { list.add(fromMongoDoc(it)) }
		return list
	}

	override Int findCount([Str:Obj?]? query := null) {
		collection.findCount(query)
	}

	@Operator
	override Obj? get(Obj? id, Bool checked := true) {
		if (id != null && !ReflectUtils.fits(id.typeof, idField.type))
			throw ArgErr(ErrMsgs.datastore_idDoesNotFit(id, idField))
		mongId := toMongo(id)
		entity := collection.get(mongId, checked)
		return (entity == null) ? null : fromMongoDoc(entity)
	}

	// ---- Write Operations ----------------------------------------------------------------------

	override Obj insert(Obj entity) {
		if (!entity.typeof.fits(type))
			throw ArgErr(ErrMsgs.datastore_entityWrongType(entity.typeof, type))
		collection.insert(toMongoDoc(entity))
		return entity
	}

	override Void delete(Obj entity, Bool checked := true) {
		if (!entity.typeof.fits(type))
			throw ArgErr(ErrMsgs.datastore_entityWrongType(entity.typeof, type))
		id := idField.get(entity)
		deleteById(id, checked)
	}

	override Void deleteById(Obj id, Bool checked := true) {
		if (!ReflectUtils.fits(id.typeof, idField.type))
			throw ArgErr(ErrMsgs.datastore_idDoesNotFit(id, idField))
		mongId := toMongo(id)
		n := collection.delete(["_id" : mongId], false)
		if (checked && n != 1)
			throw MorphiaErr(ErrMsgs.datastore_entityNotFound(type, id))
	}

	override Void update(Obj entity, Bool? upsert := false, Bool checked := true) {
		if (!entity.typeof.fits(type))
			throw ArgErr(ErrMsgs.datastore_entityWrongType(entity.typeof, type))
		id := idField.get(entity)
		mongId := toMongo(id)
		noOfUpdates := collection.update(["_id" : mongId], toMongoDoc(entity), false, upsert)
		if (noOfUpdates == 0 && upsert == false && checked) {
			// Mongo reports zero updates if the given document hasn't changed,
			// as this isn't an error let it slide...
			if (collection.get(mongId, false) == null)
				throw MorphiaErr(ErrMsgs.datastore_entityNotFound(type, mongId))
		}
	}

	// ---- Aggregation Commands ------------------------------------------------------------------

	override Int size() {
		collection.size
	}
	
	// ---- Conversion Methods --------------------------------------------------------------------
	
	override Obj fromMongoDoc(Str:Obj? mongoDoc) {
		converters.toFantom(type, mongoDoc)
	}
	
	override Str:Obj? toMongoDoc(Obj entity) {
		converters.toMongo(type, entity)		
	}	

	internal Obj? toMongo(Obj? entity) {
		entity == null ? null : converters.toMongo(entity.typeof, entity)		
	}	

	// ---- Query Methods -------------------------------------------------------------------------
	
	override QueryExecutor query(Query? query := null) {
		// nullable query so we can do: ds.query.findAll
		QueryExecutor(this, query ?: Query())
	}
	
	// ---- Helper Methods ------------------------------------------------------------------------
	
	internal Type verifyEntityType(Type type) {
		// try to use the ObjConverter hook to find property fields
		fields := (Field[]?) (converters.get(Obj#) as ObjConverter)?.findPropertyFields(type)
		
		// if null, we can't be sure what fields are valid, so skip validation
		if (fields == null)
			return type
	
		names := Str:Field[:]
		fields.each |field| {
			pName := Utils.propertyName(field)
			pType := Utils.propertyType(field)
			if (!ReflectUtils.fits(pType, field.type))
				throw MorphiaErr(ErrMsgs.datastore_facetTypeDoesNotFitField(pType, field))
			if (names.containsKey(pName))
				throw MorphiaErr(ErrMsgs.datastore_duplicatePropertyName(pName, names[pName], field))
			names[pName] = field 
		}
		return type
	}
	
	private static Str[] propertyNames(Type type) {
		type.fields.findAll { it.hasFacet(Property#) }.map |field->Str| {
			property := (Property) field.facet(Property#)
			return property.name ?: field.name			
		}
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
