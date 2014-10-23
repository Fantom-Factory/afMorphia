using afBson

** A means to build Mongo queries with sane objects and methods. (And not some incomprehensible mess of nested maps and lists!)
** 
** Pass 'Query' objects to a `QueryExecutor` to run them.
class Query {
	
	private |Datastore, Str:Obj|[] _toMongoFuncs	:= [,]
	
	** Creates a match for the given field name. It may reference nested objects using dot notation. Example, 'user.name'
	** 
	** Note this is actually the MongoDB property name and *not* the field name. 
	** Though, the two are usually the same unless you use the '@Property.name' attribute. 
	QueryCriterion field(Str fieldName) {
		// todo: validate field exists
		// Note, this cannot take a field for we can't verify nested objects
		return QueryCriterion(this, fieldName)
	}

	** Selects documents based on the return value of a javascript function. Example:
	** 
	**   Query().where(Code("this.name == 'Judge Dredd'"))
	** 
	** As only 1 *where* function is allowed per query, only the last *where* function is used.
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/where/`
	Query where(Code where) {
		_addFunc |Datastore datastore, Str:Obj mongoQuery| {
			mongoQuery["\$where"] = where
		}
	}

	** Selects documents that pass all the query expressions in the given list.
	** Example:
	** 
	**   Query().and([
	**     Query().field("quantity").lessThan(20),
	**     Query().field("price").eq(10)
	**   ])
	** 
	** Note the above could also be written implicitly with:
	** 
	**   Query().field("quantity").lessThan(20).field("price").eq(10)
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/and/`
	Query and(Query[] criteria) {
		_addFunc |Datastore datastore, Str:Obj mongoQuery| {
			mongoQuery.add("\$and", criteria.map { it.toMongo(datastore) })
		}
	}	

	** Selects documents that pass any of the query expressions in the given list.
	** Example:
	** 
	**   Query().or([
	**     Query().field("quantity").lessThan(20),
	**     Query().field("price").eq(10)
	**   ])
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/or/`
	Query or(Query[] criteria) {
		_addFunc |Datastore datastore, Str:Obj mongoQuery| {
			mongoQuery.add("\$or", criteria.map { it.toMongo(datastore) })
		}
	}	

	** Selects documents that fail **all** the query expressions in the given list.
	** Example:
	** 
	**   Query().or([
	**     Query().field("quantity").lessThan(20),
	**     Query().field("price").eq(10)
	**   ])
	** 
	** @see `http://docs.mongodb.org/manual/reference/operator/query/nor/`
	Query nor(Query[] criteria) {
		_addFunc |Datastore datastore, Str:Obj mongoQuery| {
			mongoQuery.add("\$nor", criteria.map { it.toMongo(datastore) })
		}
	}
	
	** Returns a Mongo document representing the query. 
	** May be used by `DataStore` and [Collection]`afMongo::Collection` methods such as 'findAndUpdate(...)'.  
	[Str:Obj] toMongo(Datastore datastore) {
		mongoQuery := Str:Obj[:] { ordered = true }
		_toMongoFuncs.each { it.call(datastore, mongoQuery) }
		return mongoQuery
	}
	
	internal This _addFunc(|Datastore, Str:Obj| func) {
		_toMongoFuncs.add(func)
		return this
	}	
}