using afIoc

const class Serializer {

	new make(|This|in) { in(this) }
	
	Obj fromMongoDoc(Str:Obj? mongoDoc, Type type) {
		
		// TODO: will turn into IoC autobuild... somehow
		maker := Maker(type)
		
		type.fields.each {
			maker[f] = mongoDoc[it.name]
		}
		
		return maker.make
	}
	
	Str:Obj? toMongoDoc(Obj entity, Type type) {
		[:]
	}
}
