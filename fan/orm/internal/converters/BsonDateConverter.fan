
internal const class BsonDateConverter : BsonConverter {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Date) fantomObj).midnight(TimeZone.utc)
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConverterCtx ctx) {
		if (bsonVal == null) return null
		return ((DateTime) bsonVal).date
	}
}
