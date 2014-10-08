
// https://morphia.googlecode.com/svn/site/morphia/apidocs/com/google/code/morphia/query/FieldEnd.html
class QueryProjection {
	private Str?	_fieldName
	private Query	_query

	internal new make(Query query, Str fieldName) {
		this._query 	= query
		this._fieldName = fieldName
	}
		
	Query eq(Obj value) {
		_query[_fieldName] = _query._converters.toMongo(value)
		return _query
	}

	Query eqIgnoreCase(Str value) {
		_query[_fieldName] = "(?i)^${quoteRegex(value.trim)}\$".toRegex
		return _query
	}

	Query contains(Str value) {
		_query[_fieldName] = "${quoteRegex(value.trim)}".toRegex
		return _query
	}

	Query containsIgnoreCase(Str value) {
		_query[_fieldName] = "(?i)${quoteRegex(value.trim)}".toRegex
		return _query
	}

	Query in(Obj[] values) {
		_query[_fieldName] = map["\$in"] = values.map { _query._converters.toMongo(it) }
		return _query
	}
	
	// TODO: Fantom-1.0.67
	private static Regex quoteRegex(Str str) {
		quoted := StrBuf()
		str.each |c| {   
			if (!c.isAlphaNum) quoted.addChar('\\')
			quoted.addChar(c)
		}
		return quoted.toStr.toRegex
	}

	private static Str:Obj map() {
		Str:Obj[:] { ordered = true }
	}
}

