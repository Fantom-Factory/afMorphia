
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
mixin Queries {

	** Returns a singleton instance of 'Queries'. Use when you'd rather not inherit from 'Queries'.
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
	static new instance() {
		instanceRef
	}
	
	private static const QueriesImpl instanceRef := QueriesImpl()
	
	// ---- Comparison Query Operators ------------------------------------------------------------
	
	** Matches values that are equal to the given object.
	** 
	** 'name' may either a MongoDB property name (Str) or a field annotated with '@Property'.
	Query eq(Obj name, Obj? value) {
		Query().field(name).eq(value)
	}

	** Matches values that are **not** equal to the given object.
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/ne/`
	Query notEq(Obj name, Obj? value) {
		Query().field(name).notEq(value)
	}

	** Matches values that equal any one of the given values.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/in/`
	Query in(Obj name, Obj[] values) {
		Query().field(name).in(values)
	}

	** Matches values that do **not** equal any one of the given values.
	** 
	** Note this also matches documents that do not contain the field.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/nin/`
	Query notIn(Obj name, Obj[] values) {
		Query().field(name).notIn(values)
	}

	** Matches values that are greater than the given object.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gt/`
	Query greaterThan(Obj name, Obj value) {
		Query().field(name).greaterThan(value)
	}

	** Matches values that are greater than or equal to the given object.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gte/`
	Query greaterThanOrEqTo(Obj name, Obj value) {
		Query().field(name).greaterThanOrEqTo(value)
	}

	** Matches values that are less than the given object.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/gt/`
	Query lessThan(Obj name, Obj value) {
		Query().field(name).lessThan(value)
	}

	** Matches values that are less than or equal to the given object.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/lte/`
	Query lessThanOrEqTo(Obj name, Obj value) {
		Query().field(name).lessThanOrEqTo(value)
	}

	// ---- Element Query Operators ---------------------------------------------------------------

	** Matches if the field exists (or not), even if it is 'null'.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/exists/`
	Query exists(Obj name, Bool exists := true) {
		Query().field(name).exists(exists)
	}
	
	// ---- String Query Operators ----------------------------------------------------------------
	
	** Matches string values that equal the given regular expression.
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	Query matchesRegex(Obj name, Regex regex) {
		Query().field(name).matchesRegex(regex)
	}

	** Matches string values that equal (ignoring case) the given value.
	** 
	** Note that matching is performed with regular expressions. 
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	Query eqIgnoreCase(Obj name, Str value) {
		Query().field(name).eqIgnoreCase(value)
	}

	** Matches string values that contain the given value.
	** 
	** Note that matching is performed with regular expressions. 
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	Query contains(Obj name, Str value, Bool caseInsensitive := true) {
		Query().field(name).contains(value, caseInsensitive)
	}

	** Matches string values that start with the given value.
	** 
	** Note that matching is performed with regular expressions. 
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	Query startsWith(Obj name, Str value, Bool caseInsensitive := true) {
		Query().field(name).startsWith(value, caseInsensitive)
	}

	** Matches string values that end with the given value.
	** 
	** Note that matching is performed with regular expressions. 
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	Query endsWith(Obj name, Str value, Bool caseInsensitive := true) {
		Query().field(name).endsWith(value, caseInsensitive)
	}

	// ---- Evaluation Query Operators ------------------------------------------------------------

	** Matches values based on their remainder after a division (modulo operation).
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/mod/`
	Query mod(Obj name, Int divisor, Int remainder) {
		Query().field(name).mod(divisor, remainder)
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
	
	** Performs a text search on the collection. 
	** 
	** Text searching makes use of stemming and ignores language stop words.
	** Quotes may be used to search for exact phrases and prefixing a word with a hyphen-minus (-) negates it.
	** 
	** Results are automatically ordered by search relevance.
	**  
	** To use text searching, make sure the Collection has a text Index else MongoDB will throw an Err.
	** 
	** 'options' may include the following:
	** 
	**   table:
	**   Name                 Type  Desc
	**   ----                 ----  ----                                              
	**   $language            Bool  Determines the list of stop words for the search and the rules for the stemmer and tokenizer. See [Supported Text Search Languages]`https://docs.mongodb.com/manual/reference/text-search-languages/#text-search-languages`. Specify 'none' for simple tokenization with no stop words and no stemming. Defaults to the language of the index.
	**   $caseSensitive       Bool  Enable or disable case sensitive searching. Defaults to 'false'.
	**   $diacriticSensitive  Int   Enable or disable diacritic sensitive searching. Defaults to 'false'.
	** 
	** @see `https://docs.mongodb.com/manual/reference/operator/query/text/`.
	Query textSearch(Str search, [Str:Obj?]? options := null) {
		Query().textSearch(search, options)
	}
}

internal const class QueriesImpl : Queries { }
