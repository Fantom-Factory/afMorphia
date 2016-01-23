
** A utility `Converter` that handles simple serializable types. 
const class SimpleConverter : Converter {
	private const Type type
	
	** Creates a converter for the given type. The type must be annotated with:
	** 
	**   syntax: fantom
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
		fromStr := type.method("fromStr", true)
		try {
			return fromStr.call(mongoObj)
		} catch (Err err) {
			throw MorphiaErr("Could not call ${fromStr.qname} ${fromStr.signature} with ${mongoObj.typeof.qname}", err)
		}
	}

	@NoDoc
	override Obj? toMongo(Type type, Obj? fantomObj) {
		fantomObj?.toStr
	}
	
	@NoDoc
	override Str toStr() {
		"Simple Converter for ${type.qname}"
	}
}
