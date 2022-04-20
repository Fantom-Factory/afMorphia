
internal const class BsonSlotConverter : BsonConverter {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConverterCtx ctx) {
		if (fantomObj == null) return null
		return ((Slot) fantomObj).qname
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConverterCtx ctx) {
		if (bsonVal == null) return null
		return Slot.find((Str) bsonVal)
	}
}
