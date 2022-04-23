
internal const class BsonEnumConv : BsonConv {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) {
		if (fantomObj == null) return null
		return ((Enum) fantomObj).name
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) {
		if (bsonVal == null) return null
		return ctx.type.method("fromStr").call(bsonVal, true)
	}
}
