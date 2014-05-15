
** Implement to convert a non-standard Fantom type to / from a MongoDB representation. 
const mixin Converter {

	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)
	
	abstract Obj? toMongo(Obj fantomObj)
	
}
