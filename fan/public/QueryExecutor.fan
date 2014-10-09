
** Executes a query built from `Query` objects. 
class QueryExecutor {
	private Datastore	_datastore
	private [Str:Obj]	_query
	private [Str:Obj]?	_sortBy

	** Starts the query results at a particular zero-based offset.
	** 
	** Only used by 'findAll()'. 
	Int skip	:= 0

	** Limits the fetched result set to a certain number of values. 
	** A value of 'null' or '0' indicates no limit.
	** 
	** Only used by 'findAll()'. 
	Int? limit	:= null
	
	** Creates a 'QueryExecutor' to run the given query against the datastore.
	new make(Datastore datastore, Query query) {
		this._datastore  = datastore
		this._query 	 = query.toMongo(datastore)
	}
	
	** TODO: Use '-' for desc
	** TODO: allow multiple sortBy() calls
	This sortBy(Str fieldName) {
		// TODO: check field exists
		// TODO: take an Obj, rename to just field() and check for Str or Field
		_sortBy = map[fieldName] = "ASC"
		return this
	}

	** An (optomised) method to return one document from the query.
	** 
	** Throws 'MongoErr' if no documents are found and 'checked' is 'true', returns 'null' otherwise.
	** Always throws 'MongoErr' if the query returns more than one document.
	**  
	** @see `afMongo::Collection.findOne`
	Obj? findOne(Bool checked := true) {
		_datastore.findOne(_query, checked)
	}

	** Returns a list of entities that match the query.
	** 
	** @see `afMongo::Collection.findAll`
	Obj[] findAll() {
		_datastore.findAll(_query, _sortBy, skip, limit)
	}
	
	** Returns the number of documents that would be returned by the query.
	** 
	** @see `afMongo::Collection.findCount`
	Int findCount(Str:Obj? query) {
		_datastore.findCount(_query)
	}

	** Returns a Mongo document representing the query. 
	** May be used by `Datastore` and [Collection]`afMongo::Collection` methods such as 'findAndUpdate(...)'.  
	Str:Obj? mongoQuery() {
		_query
	}
	
	private static Str:Obj map() {
		Str:Obj[:] { ordered = true }
	}
}