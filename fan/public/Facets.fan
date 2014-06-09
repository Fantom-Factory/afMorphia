
** Marks a type to be mapped as a top level document in a MongoDB collection.
facet class Entity {
	
	** The name of the MongoDB collection to store the documents in.
	** 
	** Defaults to the type name.
	const Str? name
}

** Marks a field as a property of a MongoDB document.
facet class Property {

	** The name of the key to store the field in.
	** 
	** Defaults to the field name.
	const Str? 	name

	** The actual type to be instantiated.
	** 
	** Defaults to the field type.
	const Type? type
}

** Use in conjunction with '@Inject' to specify which 'Datastore' to inject.
facet class DatastoreType {
	
	** The entity type
	const Type type
	
}