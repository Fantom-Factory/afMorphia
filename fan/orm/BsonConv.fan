
** Implement to convert custom Fantom types to / from a BSON representation. 
const mixin BsonConv {
	
	** Converts a Fantom object to its BSON representation. 
	** 
	** Must return a valid BSON value (or a List or Map thereof).
	** 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	abstract Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx)

	** Converts a BSON value to Fantom.
	** 
	** 'bsonVal' is nullable so converters can create empty / default objects.
	abstract Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx)
	
}
