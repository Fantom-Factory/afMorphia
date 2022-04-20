
internal const class BsonTypeConverter : BsonConverter {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Type) fantomObj).signature
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConverterCtx ctx) {
		if (bsonVal == null) return null
		return Type.find((Str) bsonVal)
	}
}
