
** Implement to convert custom Fantom types to / from a MongoDB representation. 
** 
** For more control over how a specific Fantom type is mapped to / from Mongo documents, create an implementation of 'Converter' for that type. 
** Then, in the 'AppModule', contribute an instance of the 'Converter' to the 'Converters' service:
**
**   syntax: fantom
** 
**   @Contribute { serviceType=Converters# }
**   static Void contributeConverters(Configuration config) {
**       config[MyType#] = MyTypeConverter()
**   } 
**  
** The contribution key *must* be the type that the converter, converts.
const mixin Converter {

	** Converts a Mongo object to Fantom.
	** 
	** 'mongoObj' is nullable so converters can create empty / default objects.
	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)
	
	** Converts a Fantom object to its Mongo representation. 
	** 
	** Must return a valid BSON type (or a List or Map thereof).
	** 
	** 'fantomType' is required in case 'fantomObj' is null. 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	abstract Obj? toMongo(Type fantomType, Obj? fantomObj)
	
}
