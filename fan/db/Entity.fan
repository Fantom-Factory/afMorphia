
** Marks a type to be mapped as a top level document in a MongoDB collection.
@FacetMeta { inherited = true }
facet class Entity {
	
	** Name of the MongoDB collection that documents are stored under. 
	** 
	** Defaults to the type name.
	const Str? name
}
