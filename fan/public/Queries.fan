
** Convenience shortcut methods for creating 'Query' objects.
** These values mimic those on `QueryCriterion`.
** 
** pre>
** syntax: fantom
** 
** const class MyQueries : Queries {
** 
**     Query price() {
**         return and([
**             or([ eq("price", 0.99f), eq("price", 1.99f)  ]),
**             or([ eq("sale", true),   lessThan("qty", 29) ])
**         ])
**     }
** <pre
const mixin Queries {

	** Returns an instance of 'Queries'. Use when you'd rather not inherit from 'Queries'.
	** 
	** pre>
	** syntax: fantom
	** 
	** Query price() {
	**     q := Queries()
	**     return q.or([
	**         q.eq("price", 0.99f), 
	**         q.eq("price", 1.99f)
	**     ])
	** }
	** <pre
	static new makeInstance() {
		instance
	}
	
	private static const Queries instance := QueriesImpl()
	
	// ---- Comparison Query Operators ------------------------------------------------------------
	
	** Matches values that are equal to the given object.
	Query eq(Str fieldName, Obj? value) {
		Query().field(fieldName).eq(value)
	}

	** Matches values that are **not** equal to the given object.
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/ne/`
	Query notEq(Str fieldName, Obj? value) {
		Query().field(fieldName).notEq(value)
	}

	** Matches values that equal any one of the given values.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/in/`
	Query in(Str fieldName, Obj[] values) {
		Query().field(fieldName).in(values)
	}

	** Matches values that do **not** equal any one of the given values.
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/nin/`
	Query notIn(Str fieldName, Obj[] values) {
		Query().field(fieldName).notIn(values)
	}

	** Matches values that are greater than the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gt/`
	Query greaterThan(Str fieldName, Obj value) {
		Query().field(fieldName).greaterThan(value)
	}

	** Matches values that are greater than or equal to the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gte/`
	Query greaterThanOrEqTo(Str fieldName, Obj value) {
		Query().field(fieldName).greaterThanOrEqTo(value)
	}

	** Matches values that are less than the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gt/`
	Query lessThan(Str fieldName, Obj value) {
		Query().field(fieldName).lessThan(value)
	}

	** Matches values that are less than or equal to the given object.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/lte/`
	Query lessThanOrEqTo(Str fieldName, Obj value) {
		Query().field(fieldName).lessThanOrEqTo(value)
	}

	// ---- Element Query Operators ---------------------------------------------------------------

	** Matches if the field exists (or not), even if it is 'null'.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/exists/`
	Query exists(Str fieldName, Bool exists := true) {
		Query().field(fieldName).exists(exists)
	}
	
	// ---- String Query Operators ----------------------------------------------------------------
	
	** Matches string values that equal the given regular expression.
	Query matchesRegex(Str fieldName, Regex regex) {
		Query().field(fieldName).matchesRegex(regex)
	}

	** Matches string values that equal (ignoring case) the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query eqIgnoreCase(Str fieldName, Str value) {
		Query().field(fieldName).eqIgnoreCase(value)
	}

	** Matches string values that contain the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query contains(Str fieldName, Str value, Bool caseInsensitive := true) {
		Query().field(fieldName).contains(value, caseInsensitive)
	}

	** Matches string values that start with the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query startsWith(Str fieldName, Str value, Bool caseInsensitive := true) {
		Query().field(fieldName).startsWith(value, caseInsensitive)
	}

	** Matches string values that end with the given value.
	** 
	** Note that matching is performed with regular expressions. 
	Query endsWith(Str fieldName, Str value, Bool caseInsensitive := true) {
		Query().field(fieldName).endsWith(value, caseInsensitive)
	}

	// ---- Evaluation Query Operators ------------------------------------------------------------

	** Matches values based on their remainder after a division (modulo operation).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/mod/`
	Query mod(Str fieldName, Int divisor, Int remainder) {
		Query().field(fieldName).mod(divisor, remainder)
	}
	
	// ---- Logical Query Operators ---------------------------------------------------------------
	
	** Selects documents that do **not** match the given following criterion.
	** Example:
	** 
	**   not(Query.field("price")).lessThan(10)
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/not/`
	QueryCriterion not(QueryCriterion query) {
		query.not
	}
	
	** Selects documents that pass all the query expressions in the given list.
	** Example:
	** 
	**   syntax: fantom
	**   query := and(
	**     lessThan("quantity", 20),
	**     eq("price", 10)
	**   )
	** 
	** Note the above could also be written as:
	** 
	**   syntax: fantom
	**   lessThan("quantity", 20).and([eq("price", 10)])
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/and/`
	Query and(Query q1, Query q2, Query? q3 := null, Query? q4 := null) {
		qs := [q1, q2]
		if (q3 != null)
			qs.add(q3)
		if (q4 != null)
			qs.add(q4)
		return Query().and(qs)
	}

	** Selects documents that pass any of the query expressions in the given list.
	** Example:
	** 
	**   syntax: fantom
	**   query := or(
	**     lessThan("quantity", 20),
	**     eq("price", 10)
	**   )
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/or/`
	Query or(Query q1, Query q2, Query? q3 := null, Query? q4 := null) {
		qs := [q1, q2]
		if (q3 != null)
			qs.add(q3)
		if (q4 != null)
			qs.add(q4)
		return Query().or(qs)
	}

	** Selects documents that fail **all** the query expressions in the given list.
	** Example:
	** 
	**   syntax: fantom
	**   query := nor(
	**     lessThan("quantity", 20),
	**     eq("price", 10)
	**   )
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/nor/`
	Query nor(Query q1, Query q2, Query? q3 := null, Query? q4 := null) {
		qs := [q1, q2]
		if (q3 != null)
			qs.add(q3)
		if (q4 != null)
			qs.add(q4)
		return Query().nor(qs)
	}
}

internal const class QueriesImpl : Queries { }
