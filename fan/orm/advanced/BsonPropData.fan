using afBeanUtils::ReflectUtils

** Holds resolved '@BsonProp' values.
@NoDoc	// Advanced use only
const class BsonPropData {
	
	** The backing storage field.
	const	Field field
	
	** The 'BsonProp' facet on the field (if any).
	const	BsonProp? bsonProperty
	
	** Name of the BSON property name this field maps to.
	const	Str	name
	
	** The implementation 'Type' to be instantiated.
	const	Type type
	
	** The default values that maps to 'null'.
	const	Obj? defVal
	
	** Standard it-block ctor.
	new make(|This| f) { f(this) }
	
	** Creates a 'BsonPropData' instance from a 'Field' - may have the '@BsonProp' facet.
	new fromField(Field field, |This|? fn := null) {
		this.field			= field
		this.bsonProperty	= field.facet(BsonProp#, false)
		this.name			= bsonProperty?.name		?: field.name
		this.type			= bsonProperty?.implType	?: field.type
		this.defVal			= bsonProperty?.defVal

		fn?.call(this)
		
		if (!ReflectUtils.fits(type, field.type))
			throw Err(msgFacetTypeDoesNotFitField(type, field))

		// ReflectUtils.fits is too lenient for our purposes here 
		if (defVal is List && ((List) defVal).isEmpty && !defVal.typeof.fits(field.type))
			defVal = field.type.params["V"].emptyList

		// ReflectUtils.fits is too lenient for our purposes here 
		if (defVal is Map && ((Map) defVal).isEmpty && !defVal.typeof.fits(field.type))
			defVal = Map.make(field.type)
		
		if (defVal != null && !ReflectUtils.fits(defVal.typeof, field.type))
			throw Err(msgFacetDefValDoesNotFitField(defVal.typeof, field))
	}
	
	private static Str msgFacetTypeDoesNotFitField(Type facetType, Field field) {
		stripSys("@BsonProp.implType of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
	}

	private static Str msgFacetDefValDoesNotFitField(Type facetType, Field field) {
		stripSys("@BsonProp.defVal of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}

	** Returns the field's value on the given instance.
	virtual Obj? val(Obj obj) {
		field.get(obj)
	}

	override Str toStr() { name }
}
