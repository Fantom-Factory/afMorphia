using afBson
using afMongo::PrettyPrinter

** A means to build Mongo queries with sane objects and methods. (And not some incomprehensible mess of nested maps and lists!)
** 
** Pass 'Query' objects to a `QueryExecutor` to run them.
class Query {
	
	private |Datastore?, Str:Obj|[] _toMongoFuncs	:= |Datastore?, Str:Obj|[,]
	
	** Creates a match for the given field name. It may reference nested objects using dot notation. Example, 'user.name'
	** 
	** 'name' may either an entity 'Field' annotated with '@Property' or a MongoDB property name (Str).
	QueryCriterion field(Obj name) {
		fieldName := Utils.objToPropertyName(name)
		return QueryCriterion(this, fieldName)
	}

	**
	** 
	**   table:
	**   Name                 Type  Desc
	**   ----                 ----  ----                                              
	**   $language            Bool  Determines the list of stop words for the search and the rules for the stemmer and tokenizer. See [Supported Text Search Languages]`https://docs.mongodb.com/manual/reference/text-search-languages/#text-search-languages`. Specify 'none' for simple tokenization with no stop words and no stemming. Defaults to the language of the index.
	**   $caseSensitive       Bool  Enable or disable case sensitive searching. Defaults to 'false'.
	**   $diacriticSensitive  Int   Enable or disable diacritic sensitive searching. Defaults to 'false'.
	**  
	Query textSearch(Str search, [Str:Obj?]? options := null) {
		_addFunc |Datastore? datastore, Str:Obj mongoQuery| {
			mongoQuery["\$text"] = (options?.dup ?: Str:Obj?[:]).add("\$search", search)
		}		
	}
	
	** Selects documents based on the return value of a javascript function. Example:
	** 
	**   syntax: fantom
	**   Query().where(Code("this.name == 'Judge Dredd'"))
	** 
	** As only 1 *where* function is allowed per query, only the last *where* function is used.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/where/`
	Query where(Code where) {
		_addFunc |Datastore? datastore, Str:Obj mongoQuery| {
			mongoQuery["\$where"] = where
		}
	}

	** Selects documents that pass all the query expressions in the given list.
	** Example:
	** 
	**   syntax: fantom
	**   Query().and([
	**     Query().field("quantity").lessThan(20),
	**     Query().field("price").eq(10)
	**   ])
	** 
	** Note the above could also be written implicitly with:
	** 
	**   syntax: fantom
	**   Query().field("quantity").lessThan(20).field("price").eq(10)
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/and/`
	Query and(Query[] criteria) {
		_addFunc |Datastore? datastore, Str:Obj mongoQuery| {
			mongoQuery.add("\$and", criteria.map { it._toMongo(datastore) })
		}
	}	

	** Selects documents that pass any of the query expressions in the given list.
	** Example:
	** 
	**   syntax: fantom
	**   Query().or([
	**     Query().field("quantity").lessThan(20),
	**     Query().field("price").eq(10)
	**   ])
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/or/`
	Query or(Query[] criteria) {
		_addFunc |Datastore? datastore, Str:Obj mongoQuery| {
			mongoQuery.add("\$or", criteria.map { it._toMongo(datastore) })
		}
	}	

	** Selects documents that fail **all** the query expressions in the given list.
	** Example:
	** 
	**   syntax: fantom
	**   Query().nor([
	**     Query().field("quantity").lessThan(20),
	**     Query().field("price").eq(10)
	**   ])
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/nor/`
	Query nor(Query[] criteria) {
		_addFunc |Datastore? datastore, Str:Obj mongoQuery| {
			mongoQuery.add("\$nor", criteria.map { it._toMongo(datastore) })
		}
	}

	** Returns a Mongo document representing the query. 
	** May be used by `Datastore` and [Collection]`afMongo::Collection` methods such as 'findAndUpdate(...)'.  
	[Str:Obj] toMongo(Datastore datastore) {
		_toMongo(datastore)
	}

	** Pretty prints a basic representation of the query.
	** 
	** Note that entity values are not converted to their Mongo equivalents.
	override Str toStr() {
		PrettyPrinter { it.maxWidth=40 }.print(_toMongo(null))		
	}
	
	private [Str:Obj] _toMongo(Datastore? datastore) {
		mongoQuery := Str:Obj[:] { ordered = true }
		_toMongoFuncs.each { it.call(datastore, mongoQuery) }
		return mongoQuery
	}
	
	internal This _addFunc(|Datastore?, Str:Obj| func) {
		_toMongoFuncs.add(func)
		return this
	}	
}
