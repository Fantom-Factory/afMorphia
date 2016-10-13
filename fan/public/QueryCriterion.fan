
** Defines match criterion for a field.
** Created and returned from 'Query.field()' methods.
// TODO add 'where' clause - https://docs.mongodb.com/manual/reference/operator/query/where/
// TODO add 'text' clause - https://docs.mongodb.com/manual/reference/operator/query/text/
class QueryCriterion {
	private Str?	_fieldName
	private Query	_query
	private Bool	_not

	internal new make(Query query, Str fieldName) {
		this._query 	= query
		this._fieldName = fieldName
	}
	
	// ---- Comparison Query Operators ------------------------------------------------------------
	
	** Matches values that are equal to the given object.
	Query eq(Obj? value) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { ds?.toMongo(value) ?: value }
	}

	** Matches values that are **not** equal to the given object.
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/ne/`
	Query notEq(Obj? value) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { map["\$ne"] = ds?.toMongo(value) ?: value }
	}

	** Matches values that equal any one of the given values.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/in/`
	Query in(Obj[] values) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { map["\$in"] = values.map { ds?.toMongo(it) ?: it } }
	}

	** Matches values that do **not** equal any one of the given values.
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/nin/`
	Query notIn(Obj[] values) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { map["\$nin"] = values.map { ds?.toMongo(it) ?: it } }
	}

	** Matches values that are greater than the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gt/`
	Query greaterThan(Obj value) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { map["\$gt"] = ds?.toMongo(value) ?: value }
	}

	** Matches values that are greater than or equal to the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gte/`
	Query greaterThanOrEqTo(Obj value) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { map["\$gte"] = ds?.toMongo(value) ?: value }
	}

	** Matches values that are less than the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gt/`
	Query lessThan(Obj value) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { map["\$lt"] = ds?.toMongo(value) ?: value }
	}

	** Matches values that are less than or equal to the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/lte/`
	Query lessThanOrEqTo(Obj value) {
		_addFieldFunc |DatastoreImpl? ds -> Obj?| { map["\$lte"] = ds?.toMongo(value) ?: value}
	}

	// ---- Element Query Operators ---------------------------------------------------------------

	** Matches if the field exists (or not), even if it is 'null'.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/exists/`
	Query exists(Bool exists := true) {
		_addFieldFunc |Datastore? ds -> Obj?| 	{ map["\$exists"] = exists }
	}
	
	// ---- String Query Operators ----------------------------------------------------------------
	
	** Matches string values that equal the given regular expression.
	Query matchesRegex(Regex regex) {
		_addFieldFunc |Datastore? ds -> Obj?| 	{ map["\$regex"] = regex }
	}

	** Matches string values that equal (ignoring case) the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query eqIgnoreCase(Str value) {
		matchesRegex("(?i)^${Regex.quote(value)}\$".toRegex)
	}

	** Matches string values that contain the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query contains(Str value, Bool caseInsensitive := true) {
		i := caseInsensitive ? "(?i)" : Str.defVal
		return matchesRegex("${i}${Regex.quote(value)}".toRegex)
	}

	** Matches string values that start with the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query startsWith(Str value, Bool caseInsensitive := true) {
		i := caseInsensitive ? "(?i)" : Str.defVal
		return matchesRegex("${i}^${Regex.quote(value)}".toRegex)
	}

	** Matches string values that end with the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query endsWith(Str value, Bool caseInsensitive := true) {
		i := caseInsensitive ? "(?i)" : Str.defVal
		return matchesRegex("${i}${Regex.quote(value)}\$".toRegex)
	}

	// ---- Evaluation Query Operators ------------------------------------------------------------

	** Matches values based on their remainder after a division (modulo operation).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/mod/`
	Query mod(Int divisor, Int remainder) {
		_addFieldFunc |Datastore? ds -> Obj?| {	map["\$mod"] = [divisor, remainder] }
	}
	
	// ---- Logical Query Operators ---------------------------------------------------------------
	
	** Selects documents that do **not** match the given following criterion.
	** Example:
	** 
	**   Query.field("price").not.lessThan(10)
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/not/`
	QueryCriterion not() {
		_not = !_not	// allow clever clogs to put 'Query.field("name").not.not.eq("Dude")! 
		return this
	}
	
	// ---- Private Methods -----------------------------------------------------------------------
	
	private Query _addFieldFunc(|Datastore? -> Obj?| func) {
		_query._addFunc |Datastore? datastore, Str:Obj? mongoQuery| {
			val := func(datastore)
			if (_not)
				val = map["\$not"] = val
			
			// merge fields with an implicit AND if it already exists
			if (mongoQuery.containsKey(_fieldName)) {
				q := (Str:Obj?) mongoQuery[_fieldName]	// may fail cast if an eq() 
				q.addAll(val)
			} else
				mongoQuery[_fieldName] = val
		}
	}

	private static Str:Obj? map() {
		Str:Obj?[:] { ordered = true }
	}
}

