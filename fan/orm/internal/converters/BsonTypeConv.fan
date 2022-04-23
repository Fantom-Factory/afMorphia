
internal const class BsonTypeConv : BsonConv {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) {
		if (fantomObj == null) return null
		return ((Type) fantomObj).signature
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) {
		if (bsonVal == null) return null
		return Type.find((Str) bsonVal)
	}
}
