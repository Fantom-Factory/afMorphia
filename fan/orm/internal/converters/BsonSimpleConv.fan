
** A utility `BsonConv` that handles simple serializable types. 
internal const class BsonSimpleConv : BsonConv {
	private const Type type

	** Creates a converter for the given type. The type must be annotated with:
	** 
	**   syntax: fantom
	**   @Serializable { simple = true }
	new make(Type type) {
		serializable := (Serializable?) type.facet(Serializable#, false)
		if (serializable == null)
			throw ArgErr("Type '${type.qname}' is not @Serializable")
		if (!serializable.simple)
			throw ArgErr("Type '${type.qname}' is not @Serializable { simple=true }")
		this.type = type
	}

	@NoDoc
	override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) {
		fantomObj?.toStr
	}

	@NoDoc
	override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) {
		if (bsonVal == null) return null
		// use 'type' not 'this.type' incase we're passed a subclass
		fromStr := type.method("fromStr", true)
		try return fromStr.call(bsonVal)
		catch (Err err)
			throw Err("Could not call ${fromStr.qname} ${fromStr.signature} with ${bsonVal.typeof.qname}", err)
	}
	
	@NoDoc
	override Str toStr() {
		"Simple Converter for ${type.qname}"
	}
}
