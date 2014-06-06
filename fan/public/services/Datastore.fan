using afIoc
using afMongo

const class Datastore {

	@Inject private const Converters converters
	
	** The underlying MongoDB collection this Datastore wraps.
	const Collection collection

	const Type	type
	
	** The qualified name of the MongoDB collection.
	const Str qname

	** The simple name of the MongoDB collection.
	const Str name
	
	
	internal new make(Type type, Database database, |This|in) {
		in(this)
		// TODO: check for Document facet, use the optional name
		this.type		= type
		this.collection	= Collection(database, type.name)
		this.qname		= collection.qname
		this.name		= collection.name
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
		collection.drop
		return this
	}

	// ---- Cursor Queries ------------------------------------------------------------------------
	
	** Returns one document that matches the given 'query'.
	** 
	** Throws 'MongoErr' if no documents are found and 'checked' is true, returns 'null' otherwise.
	** Always throws 'MongoErr' if the query returns more than one document.
	**  
	** @see `afMongo::Collection.findOne`
	Obj? findOne(Str:Obj? query, Bool checked := true) {
		fromMongoDoc(collection.findOne(query, checked))
	}

	** Returns the result of the given 'query' as a list of documents.
	** If 'sort' is a Str it should the name of an index to use as a hint. 
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
	** @see `afMongo::Collection.findCount`
	Int findCount(Str:Obj? query) {
		collection.findCount(query)
	}

	** Returns the document with the given Id.
	** Convenience / shorthand notation for 'findOne(["_id": id], checked)'
	@Operator
	Obj? get(Obj id, Bool checked := true) {
		// TODO: check ID is of correct type
		fromMongoDoc(collection.get(id, checked))
	}

	// ---- Write Operations ----------------------------------------------------------------------

	** Inserts the given entity.
	** Returns the number of documents inserted.
	** 
	** @see `afMongo::Collection.insert`
	Void insert(Obj entity) {
		collection.insertMulti([toMongoDoc(entity)])
	}

//	Obj delete(Obj entity) {
//		// TODO: type check entity
//		// TODO: find the ID field in the entity
//		return entity		
//	}

	** Deletes entity with the given Id.
	** Throws 'ArgErr' if 'checked' and nothing was deleted. 
	** 
	** @see `afMongo::Collection.delete`
	Void deleteById(Obj id, Bool checked := true) {
		n := collection.delete(["_id" : id], false)
		if (checked && n != 1)
			throw ArgErr(ErrMsgs.datastore_IdNotFound(type, id))
	}

	** Updates the given entity.
	** 
	** @see `afMongo::Collection.update`
	Void update(Obj entity, Bool? upsert := false) {
//		// TODO: type check entity
//		// TODO: find the ID field in the entity
//		collection.update(["_id" : id], toMongoDoc(entity), false, upsert)
//		throw ArgErr()
	}

	// ---- Aggregation Commands ------------------------------------------------------------------

	** Returns the number of documents in the collection.
	** 
	** @see `afMongo::Collection.size`
	Int size() {
		collection.size
	}
	
	// ---- Conversion Methods --------------------------------------------------------------------
	
	Obj fromMongoDoc(Str:Obj? mongoDoc) {
		converters.toFantom(type, mongoDoc)
	}
	
	Str:Obj? toMongoDoc(Obj entity) {
		converters.toMongo(entity)		
	}	
}
