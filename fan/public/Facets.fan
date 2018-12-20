using afBeanUtils::ReflectUtils

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
	const Type? implType
	
	** When saving to MongoDB, any Fantom value that equals this 'defVal' will be treated as if 
	** it were 'null' and (depending on 'ObjConverter') will *not* be saved.
	** 
	** When loaded from MongoDB, any 'null' value will be converted to this 'defVal'.
	** 
	** This is most useful for saving marker booleans and to avoid saving empty lists and maps.
	const Obj? defVal
}

** Holds resolved '@Property' values.
@NoDoc
const mixin PropertyData {
	
	** The backing storage field.
	abstract	Field	field()
	
	** Name of the MongoDB object key this field maps to.
	abstract	Str 	name()
	
	** The implementation 'Type' to be instantiated.
	abstract	Type	type()
	
	** The default values that maps to 'null'.
	abstract	Obj?	defVal()

	** Returns the field's value on the given instance.
	virtual Obj? val(Obj obj) {
		field.get(obj)
	}
	
	** Creates a 'PropertyData' instance from a 'Field' - must have the '@Property' facet.
	static new make(Field propertyField) {
		PropertyDataField(propertyField)
	}
}

internal const class PropertyDataField : PropertyData {
	override const Field	field
	override const Str		name
	override const Type		type
	override const Obj?		defVal
	
	new make(Field field) {
		property := (Property) field.facet(Property#, true)
		this.field	= field
		this.name	= property.name		?: field.name
		this.type	= property.implType	?: field.type
		this.defVal	= property.defVal
		
		if (!ReflectUtils.fits(type, field.type))
			throw MorphiaErr(ErrMsgs.datastore_facetTypeDoesNotFitField(type, field))

		// ReflectUtils.fits is too lenient for our purposes here 
		if (defVal is List && ((List) defVal).isEmpty && !defVal.typeof.fits(field.type))
			defVal = field.type.params["V"].emptyList

		// ReflectUtils.fits is too lenient for our purposes here 
		if (defVal is Map && ((Map) defVal).isEmpty && !defVal.typeof.fits(field.type))
			defVal = Map.make(field.type)
		
		if (defVal != null && !ReflectUtils.fits(defVal.typeof, field.type))
			throw MorphiaErr(ErrMsgs.datastore_facetDefValDoesNotFitField(defVal.typeof, field))
	}
	
	override Str toStr() { name }
}
