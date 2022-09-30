using afBson::BsonType

internal const class BsonListConv : BsonConv {
	
	override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) {
		if (fantomObj == null) return null

		fanList	 := (List) fantomObj
		listType := fanList.typeof
		
		// if the whole list is of the same BSON type, return it as is
		if (BsonType.isBsonLiteral(fanList.of))
			return fanList
		
		return fanList.map |obj, idx| {
			obj == null
				? null
				: ctx.makeList(obj?.typeof ?: fanList.of, fanList, idx, obj).toBsonVal
		}
	}
	
	override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) {
		if (bsonVal == null) return null

		fanValType	:= ctx.type.params["V"]
		folListType	:= bsonVal.typeof
		folValType	:= folListType.params["V"]
	
		// if the whole list is of the same type, return it as is
		// but make sure we still convert Objs
		if (folValType.toNonNullable != Obj# && folValType.fits(fanValType))
			return bsonVal
		
		// the cast to (Obj?[]) is NEEDED!
		// see Nullable Generic Lists - https://fantom.org/forum/topic/2777
		bsonList	:= (List) bsonVal
		fanList		:= (Obj?[]) List(fanValType, bsonList.size)

		// for-loop to cut down on func obj creation
		for (idx := 0; idx < bsonList.size; ++idx) {
			obj := bsonList[idx]
			fan := ctx.makeList(fanValType, bsonList, idx, obj).fromBsonVal
			fanList.add(fan)
		}

		return fanList
	}
}
