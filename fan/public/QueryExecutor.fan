using afMongo::Index

** Executes `Query` objects against a `Datastore`. Example:
** 
**   syntax: fantom
**   QueryExecutor(datastore, query).skip(10).limit(50).orderBy("name").findAll
** 
** Or you can use the instance returned by 'Datastore.query(...)':
** 
**   syntax: fantom
**   datastore.query(query).orderBy("name").findAll
** 
class QueryExecutor {
	internal static const Str	_textScoreFieldName	:= "_textScore"

	private Datastore	_datastore
	private [Str:Obj]	_query
	private Obj?		_orderBy
	private Int 		_skip	:= 0
	private Int? 		_limit	:= null
	private Bool 		_textSearch
	
	
	** Creates a 'QueryExecutor' to run the given query against the datastore.
	new make(Datastore datastore, Query query) {
		this._datastore  = datastore
		this._query 	 = query.toMongo(datastore)
		this._textSearch = query._textSearch
	}
	
	** Specifies a property / field to use for ordering. 
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** If passing a 'Str', it may be prefixed with '-' to specify a descending order, otherwise 
	** ordering defaults to ascending. 
	** 
	** Multiple calls to 'orderBy()' may be made to indicate sub-sorts.
	** Example:
	** 
	**   syntax: fantom
	**   QueryExecutor(...).orderBy("name").orderBy("-value").findAll
	** 
	This orderBy(Obj name, Int sortOrder := Index.ASC) {
		fieldName := Utils.objToPropertyName(name)
		if (_orderBy is Str)
			throw ArgErr(ErrMsgs.query_canNotMixSorts(_orderBy, fieldName))
		if (_orderBy == null)
			_orderBy = map
		if (fieldName.startsWith("-"))		
			((Str:Obj?) _orderBy)[fieldName[1..-1]] = "DESC"
		else
			((Str:Obj?) _orderBy)[fieldName] = (sortOrder == Index.DESC) ? "DESC" : "ASC"
		return this
	}

	** Specifies an index to use for sorting.
	This orderByIndex(Str indexName) {
		if (_orderBy != null && _orderBy isnot Str)
			throw ArgErr(ErrMsgs.query_canNotMixSorts(indexName, _orderBy))
		_orderBy = indexName
		return this
	}

	** (Advanced)
	** Allows you to specify your own sort document.
	This orderByDoc(Str:Obj? sortDoc) {
		if (_orderBy is Str)
			throw ArgErr(ErrMsgs.query_canNotMixSorts(_orderBy, sortDoc))
		_orderBy = sortDoc
		return this
	}

	** When performing a text search, this orders the returned documents by search relevance.
	** Should only be used with 'findAll()'.
	** 
	** Note that 'Query.textSearch()' automatically sets text score ordering. 
	This orderByTextScore(Bool order := true) {
		
		if (order == true) {
			if (_orderBy is Str)
				throw ArgErr(ErrMsgs.query_canNotMixSorts(_orderBy, ["\$meta": "textScore"]))
			if (_orderBy == null)
				_orderBy = map
			((Str:Obj?) _orderBy)[_textScoreFieldName] = ["\$meta": "textScore"]
			_textSearch = true
		}

		if (order == false) {
			(_orderBy as Str:Obj?)?.remove(_textScoreFieldName)
			_textSearch = false			
		}

		return this
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
	This limit(Int? limit) {
		this._limit = limit
		return this
	}

	** An (optimised) method to return one document from the query.
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
		_datastore.findAll(_query, _orderBy, _skip, _limit, _textSearch ? [_textScoreFieldName : ["\$meta": "textScore"]] : null)
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