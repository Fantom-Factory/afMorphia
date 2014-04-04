using afIoc

const class Serializer {

	new make(|This|in) { in(this) }
	
	Obj fromMongoDoc(Str:Obj? mongoDoc, Type type) {		
		maker := Maker(type)
		
		type.fields.each |field| {
			maker[field] = mongoDoc[field.name]
		}
		
		// TODO: will turn into IoC autobuild... somehow
		return maker.make
	}
	
	Str:Obj? toMongoDoc(Obj entity) {
		mongoDoc := Str:Obj?[:]
		entity.typeof.fields.each |field| {
			val := field.get(entity)
			mongoDoc[field.name] = val
		}
		return mongoDoc
	}
}
