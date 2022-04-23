
internal const class BsonDateConv : BsonConv {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) {
		if (fantomObj == null) return null
		return ((Date) fantomObj).midnight(TimeZone.utc)
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) {
		if (bsonVal == null) return null
		return ((DateTime) bsonVal).date
	}
}
