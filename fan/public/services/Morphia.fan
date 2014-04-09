using afIoc

const class Morphia {

	@Inject private const Converters converters
	
	internal new make(|This|in) { in(this) }
	
	Obj fromMongoDoc(Type type, Str:Obj? mongoDoc) {
		converters.toFantom(type, mongoDoc)
	}
	
	Str:Obj? toMongoDoc(Obj entity) {
		converters.toMongo(entity.typeof, entity)		
	}	
}
