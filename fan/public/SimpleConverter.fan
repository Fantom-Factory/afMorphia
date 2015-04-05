
** A utility `Converter` that handles simple serializable types. 
const class SimpleConverter : Converter {
	private const Type type
	
	** Creates a converter for the given type. The type must be annotated with:
	** 
	**   @Serializable { simple = true }
	new make(Type type) {
		serializable := (Serializable?) Type#.method("facet").callOn(type, [Serializable#, false])
		if (serializable == null)
			throw ArgErr(ErrMsgs.simpleConverter_typeNotSerialisable(type))
		if (!serializable.simple)
			throw ArgErr(ErrMsgs.simpleConverter_typeNotSimpleSerialisable(type))
		this.type = type
	}

	@NoDoc
	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		// use 'type' not 'this.type' incase we're passed a subclass
		return type.method("fromStr").call(mongoObj, true)
	}

	@NoDoc
	override Obj? toMongo(Obj fantomObj) {
		fantomObj.toStr
	}
	
	@NoDoc
	override Str toStr() {
		"Simple Converter for ${type.qname}"
	}
}
