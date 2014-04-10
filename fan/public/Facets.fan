
facet class Document {
}

** Place on a field to mark it as a property of a MongoDB document.
facet class Property {
	// TODO: @Property name - check names are unique
//	** The name of the key to store the field in.
//	** 
//	** Defaults to the field name.
//	const Str? 	name
	
	** FIXME: Property @converter
//	const Type? converter
	
}

facet class Id {
}

