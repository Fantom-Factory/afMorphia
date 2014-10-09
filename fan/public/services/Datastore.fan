using afBeanUtils::NotFoundErr
using afBeanUtils::ReflectUtils
using afIoc
using afMongo

** (Service) -
** Wraps a MongoDB [Collection]`afMongo::Collection`, converting Fantom entities to / from Mongo documents.
** 
** When injecting as a service, use the '@Inject.type' attribute to state which Entity type it is for: 
** 
**   @Inject { type=MyEntity# }
**   private const Datastore myEntityDatastore
** 
** You can also autobuild a Datastore instance by passing in the entity type as a ctor param:
** 
**   registry.autobuild(Datastore#, [MyEntity#])
const class Datastore {
	
	** The underlying MongoDB collection this Datastore wraps.
	const Collection collection

	** The Fantom entity type.
	const Type	type
	
	** The qualified name of the MongoDB collection.
	const Str qname

	** The simple name of the MongoDB collection.
	const Str name
	
	@Inject
	private const Converters	converters
	private const Field 		idField
	
	internal new make(Type type, Database database, |This|in) {
		entity  := (Entity?) Type#.method("facet").callOn(type, [Entity#, false])
				?: throw ArgErr(ErrMsgs.datastore_entityFacetNotFound(type))

		in(this)

		this.type		= verifyEntityType(type)
		this.collection	= Collection(database, entity.name ?: type.name)
		this.qname		= collection.qname
		this.name		= collection.name
		idField			= type.fields.findAll { it.hasFacet(Property#) }.find |field->Bool| {
			property := (Property) Slot#.method("facet").callOn(field, [Property#])
			return field.name == "_id" || property.name == "_id"
		} ?: throw IdNotFoundErr(ErrMsgs.datastore_idFieldNotFound(type), propertyNames(type))

	}

	// ---- Collection ----------------------------------------------------------------------------

	** Returns 'true' if the underlying MongoDB collection exists.
	** 
	** @see `afMongo::Collection.exists`
	Bool exists() {
		collection.exists
	}
	
	** Drops the underlying MongoDB collection.
	** 
	** @see `afMongo::Collection.drop`
	This drop(Bool checked := true) {
		collection.drop(checked)
		return this
	}

	// ---- Cursor Queries ------------------------------------------------------------------------
	
	** An (optomised) method to return one document from the given 'query'.
	** 
	** Note: This method requires you to be familiar with Mongo query notation. If not, use the `Query` builder instead.
	** 
	** Throws 'MongoErr' if no documents are found and 'checked' is 'true', returns 'null' otherwise.
	** Always throws 'MongoErr' if the query returns more than one document.
	**  
	** @see `afMongo::Collection.findOne`
	Obj? findOne(Str:Obj? query, Bool checked := true) {
		entity := collection.findOne(query, checked)
		return (entity == null) ? null : fromMongoDoc(entity)
	}

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
	Obj[] findAll(Str:Obj? query := [:], Obj? sort := null, Int skip := 0, Int? limit := null) {
		collection.findAll(query, sort, skip, limit).map { fromMongoDoc(it) }
	}

	** Returns the number of documents that would be returned by the given 'query'.
	** 
	** Note: This method requires you to be familiar with Mongo query notation. If not, use the `Query` builder instead.
	** 
	** @see `afMongo::Collection.findCount`
	Int findCount(Str:Obj? query) {
		collection.findCount(query)
	}

	** Returns the document with the given Id.
	** Convenience / shorthand notation for 'findOne(["_id": id], checked)'
	@Operator
	Obj? get(Obj id, Bool checked := true) {
		if (!ReflectUtils.fits(id.typeof, idField.type))
			throw ArgErr(ErrMsgs.datastore_idDoesNotFit(id, idField))
		entity := collection.get(id, checked)
		return (entity == null) ? null : fromMongoDoc(entity)
	}

	// ---- Write Operations ----------------------------------------------------------------------

	** Inserts the given entity.
	** Returns the number of documents inserted.
	** 
	** @see `afMongo::Collection.insert`
	Void insert(Obj entity) {
		collection.insertMulti([toMongoDoc(entity)])
	}

	** Deletes the given entity from the MongoDB.
	** Throws 'ArgErr' if 'checked' and nothing was deleted. 
	** 
	** @see `afMongo::Collection.delete`
	Void delete(Obj entity, Bool checked := true) {
		if (!entity.typeof.fits(type))
			throw ArgErr(ErrMsgs.datastore_entityWrongType(entity.typeof, type))
		id := idField.get(entity)
		deleteById(id, checked)		
	}

	** Deletes entity with the given Id.
	** Throws 'ArgErr' if 'checked' and nothing was deleted. 
	** 
	** @see `afMongo::Collection.delete`
	Void deleteById(Obj id, Bool checked := true) {
		if (!ReflectUtils.fits(id.typeof, idField.type))
			throw ArgErr(ErrMsgs.datastore_idDoesNotFit(id, idField))
		n := collection.delete(["_id" : id], false)
		if (checked && n != 1)
			throw ArgErr(ErrMsgs.datastore_entityNotFound(type, id))
	}

	** Updates the given entity.
	** 
	** @see `afMongo::Collection.update`
	Void update(Obj entity, Bool? upsert := false) {
		if (!entity.typeof.fits(type))
			throw ArgErr(ErrMsgs.datastore_entityWrongType(entity.typeof, type))
		id := idField.get(entity)
		collection.update(["_id" : id], toMongoDoc(entity), false, upsert)
	}

	// ---- Aggregation Commands ------------------------------------------------------------------

	** Returns the number of documents in the collection.
	** 
	** @see `afMongo::Collection.size`
	Int size() {
		collection.size
	}
	
	// ---- Conversion Methods --------------------------------------------------------------------
	
	** Converts the Mongo document to an entity instance.
	** 
	** The returned object is not guaranteed to be of any particular object, 
	** for this is just a convenience for calling 'Converters.toFantom(...)'.
	Obj fromMongoDoc(Str:Obj? mongoDoc) {
		converters.toFantom(type, mongoDoc)
	}
	
	** Converts the entity instance to a Mongo document.
	** 
	** Actually, 'entity' maybe any Fantom object and not just an entity,
	** for this is just a convenience for calling 'Converters.toMongo(...)'.
	Str:Obj? toMongoDoc(Obj entity) {
		converters.toMongo(entity)		
	}	

	** Converts the value to a Mongo object.
	** 
	** Convenience for calling 'Converters.toMongo(...)'.
	Obj? toMongo(Obj? entity) {
		converters.toMongo(entity)		
	}	

	// ---- Query Methods -------------------------------------------------------------------------
	
	** Returns a `Query` object used to build Mongo queries.
	QueryExecutor query(Query? query := null) {
		// nullable query so we can do: ds.query.findAll
		QueryExecutor(this, query ?: Query())
	}
	
	// ---- Helper Methods ------------------------------------------------------------------------
	
	internal static Type verifyEntityType(Type type) {
		names := Str:Field[:]
		type.fields.findAll { it.hasFacet(Property#) }.each |field| {
			property := (Property) Slot#.method("facet").callOn(field, [Property#])
			pName := property.name ?: field.name
			pType := property.type ?: field.type
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
			property := (Property) Slot#.method("facet").callOn(field, [Property#])
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
