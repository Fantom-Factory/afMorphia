
const mixin Converter {

	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)
	
	abstract Obj? toMongo(Obj fantomObj)
	
}
