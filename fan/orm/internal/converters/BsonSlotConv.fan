
internal const class BsonSlotConv : BsonConv {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) {
		if (fantomObj == null) return null
		return ((Slot) fantomObj).qname
	}

	override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) {
		if (bsonVal == null) return null
		return Slot.find((Str) bsonVal)
	}
}
