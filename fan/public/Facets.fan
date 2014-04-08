
facet class Document {
}

** Place on a field to mark it as a property of a MongoDB document.
facet class Property {
	// TODO: @Property name - check names are unique
//	** The name of the key to store the field in.
//	** 
//	** Defaults to the field name.
//	const Str? 	name
	
	** The implementation type to instantiate. 
	** FIXME: mention fromMongo() et al
//	const Type?	type
	
//	// BAD-IDEA: 'cos MongoDB treats non-existant properties as null 
//	** If true, it prevents an error from occurring if the MongoDB document does not contain a property for this field. 
//	const Bool optional := false
}

facet class Id {
}

