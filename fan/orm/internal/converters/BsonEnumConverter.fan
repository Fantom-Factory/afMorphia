
internal const class BsonEnumConverter : BsonConverter {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Enum) fantomObj).name
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConverterCtx ctx) {
		if (bsonVal == null) return null
		return ctx.type.method("fromStr").call(bsonVal, true)
	}
}
