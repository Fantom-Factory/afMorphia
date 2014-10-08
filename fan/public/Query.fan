
// TODO: move to morphia - so it converts value objs 
// copy FieldEnd, Query
class Query {
	
	private Datastore	_datastore
	internal Converters	_converters
	private [Str:Obj]?	_orderBy
	private [Str:Obj]	_query	:= map
	
	@NoDoc
	new make(Datastore datastore, Converters converters) {
		this._datastore = datastore
		this._converters = converters
	}
	
	QueryProjection field(Str fieldName) {
		// TODO: check field exists
		// TODO: take an Obj, rename to just field() and check for Str or Field
		return QueryProjection(this, fieldName)
	}

	** TODO: Use '-' for desc
	This orderBy(Str fieldName) {
		// TODO: check field exists
		// TODO: take an Obj, rename to just field() and check for Str or Field
		_orderBy = map[fieldName] = "ASC"
		return this
	}

	Obj? findOne(Bool checked := true) {
		_datastore.findOne(_query, checked)
	}

	Obj[] findAll() {
		_datastore.findAll(_query, _orderBy)
	}

	Str:Obj toMap() {
		_query
	}
	
	@Operator
	private Obj? get(Str key) { null }
	
	@Operator @NoDoc
	Void set(Str key, Obj? val) {
		_query[key] = val
	}
	
	private static Str:Obj map() {
		Str:Obj[:] { ordered = true }
	}
}