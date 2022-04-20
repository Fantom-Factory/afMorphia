
** JSON literals pass straight through.
internal const class BsonLiteralConverter : BsonConverter {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConverterCtx ctx) { fantomObj }

	override Obj? fromBsonVal(Obj? bsonVal, BsonConverterCtx ctx) { bsonVal }

}
