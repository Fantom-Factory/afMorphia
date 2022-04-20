using afBeanUtils::ReflectUtils

** Holds resolved '@BsonProperty' values.
@NoDoc
const class BsonPropertyData {
	
	** The backing storage field.
	const	Field field
	
	** The 'BsonProperty' facet on the field (if any).
	const	BsonProperty? bsonProperty
	
	** Name of the JSON property name this field maps to.
	const	Str	name
	
	** The implementation 'Type' to be instantiated.
	const	Type type
	
	** The default values that maps to 'null'.
	const	Obj? defVal
	
	** Standard it-block ctor.
	new make(|This| f) { f(this) }
	
	** Creates a 'BsonPropertyData' instance from a 'Field' - may have the '@BsonProperty' facet.
	new fromField(Field field, |This|? fn := null) {
		this.field			= field
		this.bsonProperty	= field.facet(BsonProperty#, false)
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
		stripSys("@BsonProperty.implType of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
	}

	static Str msgFacetDefValDoesNotFitField(Type facetType, Field field) {
		stripSys("@BsonProperty.defVal of type '${facetType.signature}' does not fit field '${field.type.qname} ${field.qname}'")
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
