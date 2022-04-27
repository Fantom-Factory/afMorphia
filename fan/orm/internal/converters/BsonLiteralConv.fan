
** BSON literals pass straight through.
internal const class BsonLiteralConv : BsonConv {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) { fantomObj }

	override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) { bsonVal }

}
