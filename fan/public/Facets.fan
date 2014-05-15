
** Marks a class to be mapped as a top level document in a MongoDB collection.
facet class Document {
	
	** The name of the MongoDB collection to store the documents in.
	** 
	** Defaults to the class name.
	const Str? name
}

** Marks a field as a property of a MongoDB document.
facet class Property {

	** The name of the key to store the field in.
	** 
	** Defaults to the field name.
	const Str? 	name
}
