
facet class Document {
}

** Use to mark a field as a property of a MongoDB document.
facet class Property {

	** The name of the key to store the field in.
	** 
	** Defaults to the field name.
	const Str? 	name
}

//facet class Id {
//}

