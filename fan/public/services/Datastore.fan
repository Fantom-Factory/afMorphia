using afIoc
using afMongo

// rename to Entities?
class Datastore {
	
	@Inject private const Converters converters

	private const Type	type
	private Collection 	collection
	
	internal new make(Database database, Type type, |This|in) {
		in(this)
		// TODO: check for Document facet, use the optional name
		this.collection	= Collection(database, type.name)
		this.type		= type
	}

	// ---- Cursor Queries ------------------------------------------------------------------------
	
	Obj? findById(Obj id, Bool checked := true) {
		// TODO: check ID is of correct type
		fromMongoDoc(collection.get(id, checked))
	}
	
	Obj? findOne(Str:Obj? query, Bool checked := true) {
		fromMongoDoc(collection.findOne(query, checked))
	}

	** Returns the result of the given 'query' as a list of documents.
	Obj[] findAll(Str:Obj? query := [:], Obj? sort := null, Int skip := 0, Int? limit := null) {
		collection.findAll(query, sort, skip, limit).map { fromMongoDoc(it) }
	}

	** Returns the number of documents that would be returned by the given 'query'.
	Int findCount(Str:Obj? query) {
		collection.findCount(query)
	}

	// ---- Write Operations ----------------------------------------------------------------------

	Obj upsert(Obj entity) {
		// TODO: type check entity
		collection.insert(toMongoDoc(entity))
		return entity
	}
	
	Void deleteById(Obj id) {
		// TODO: type check entity
	}

	Obj delete(Obj entity) {
		// TODO: type check entity
		return entity		
	}	
	
	// ---- Aggregation Commands ------------------------------------------------------------------

	** Returns the number of documents in the collection.
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
