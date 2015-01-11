
** Implement to convert custom Fantom types to / from a MongoDB representation. 
const mixin Converter {

	** Converts a Mongo object to Fantom.
	** 
	** 'mongoObj' is nullable so converters can create empty / default objects.
	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)
	
	** Converts a Fantom object to its Mongo representation. 
	** 
	** Must return a valid BSON type (or a List or Map thereof).
	abstract Obj? toMongo(Obj fantomObj)
	
}
