
** Marks a type to be mapped as a top level document in a MongoDB collection.
@FacetMeta { inherited = true }
facet class Entity {
	
	** Name of the MongoDB collection that documents are stored under. 
	** 
	** Defaults to the type name.
	const Str? name
}

** Marks a field as a property of a MongoDB document.
facet class Property {

	** Name of the MongoDB object key this field maps to. 
	** 
	** Defaults to the field name.
	const Str? 	name

	** The implementation 'Type' to be instantiated should this field reference a mixin or a superclass. 
	** Used when mapping from MongoDB documents to Fantom objects. 
	** 
	** Defaults to the field type.
	const Type? type
}
