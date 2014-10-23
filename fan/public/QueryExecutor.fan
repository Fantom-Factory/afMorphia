
** Executes `Query` objects against a 'Datastore'. Example:
** 
**   QueryExecutor(datastore, query).skip(10).limit(50).orderBy("name").findAll
** 
** Or you can use the instance returned by 'Datastore.query(...)':
** 
**   datastore.query(query).orderBy("name").findAll
** 
class QueryExecutor {
	private Datastore	_datastore
	private [Str:Obj]	_query
	private Obj?		_orderBy
	private Int 		_skip	:= 0
	private Int? 		_limit	:= null
	
	** Creates a 'QueryExecutor' to run the given query against the datastore.
	new make(Datastore datastore, Query query) {
		this._datastore  = datastore
		this._query 	 = query.toMongo(datastore)
	}
	
	** Specifies a property / field to use for ordering. 
	** 
	** Ordering is ascending by default. Prefix the name with '-' to specify a descending order.
	** 
	** Multiple calls to 'orderBy()' may be made to indicate sub-sorts.
	** Example:
	** 
	**   QueryExecutor(...).orderBy("name").orderBy("-value").findAll
	** 
	** Note this is actually the MongoDB property name and *not* the field name. 
	** Though, the two are usually the same unless you use the '@Property.name' attribute. 
	This orderBy(Str fieldName) {
		if (_orderBy is Str)
			throw ArgErr(ErrMsgs.query_canNotMixSorts(_orderBy, fieldName))
		if (_orderBy == null)
			_orderBy = map
		if (fieldName.startsWith("-"))		
			((Str:Obj?) _orderBy)[fieldName[1..-1]] = "DESC"
		else
			((Str:Obj?) _orderBy)[fieldName] = "ASC"
		return this
	}

	** Specifies an index to use for sorting.
	This orderByIndex(Str indexName) {
		if (_orderBy isnot Str)
			throw ArgErr(ErrMsgs.query_canNotMixSorts(indexName, _orderBy))
		_orderBy = indexName
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
		_datastore.findAll(_query, _orderBy, _skip, _limit)
	}
	
	** Starts the query results at a particular zero-based offset.
	** 
	** Only used by 'findAll()'. 
	This skip(Int skip) {
		this._skip = skip
		return this
	}

	** Limits the fetched result set to a certain number of values. 
	** A value of 'null' or '0' indicates no limit.
	** 
	** Only used by 'findAll()'. 
	This limit(Int limit) {
		this._limit = limit
		return this
	}
	
	** Returns the number of documents that would be returned by the query.
	** 
	** @see `afMongo::Collection.findCount`
	Int findCount() {
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