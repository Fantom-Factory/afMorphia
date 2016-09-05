using afIoc
using afIocConfig::Config
using afBson::ObjectId

** (Service) - Converts Fantom objects to and from their Mongo representation.
** 
** Contribute 'Converter' instances to this.
** 
**   syntax: fantom
** 
**   @Contribute { serviceType=Converters# }
**   static Void contributeConverters(Configuration config) {
**       config[MyType#] = MyTypeConverter()
**   } 
**  
** @uses a Configuration of 'Type:Converter' where 'Type' is what the 'Converter', um, converts.
const mixin Converters {

	** Converts a Mongo object to the given Fantom type.
	** 
	** 'mongoObj' is nullable so converters can choose whether or not to create empty lists and maps.
	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)

	** Converts the given Fantom object to its Mongo representation.
	** 
	** 'fantomType' is required in case 'fantomObj' is null. 
	** 'fantomObj' is nullable so converters can create empty / default objects.
	abstract Obj? toMongo(Type fantomType, Obj? fantomObj)
	
	** Returns the 'Converter' instance used to convert the given type. 
	@Operator
	abstract Converter get(Type type)
}

internal const class ConvertersImpl : Converters {
	private const CachingTypeLookup	typeLookup
	
	new make(Type:Converter converters, |This|in) {
		in(this)
		this.typeLookup = CachingTypeLookup(converters)
	}

	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		get(fantomType).toFantom(fantomType, mongoObj)
	}

	override Obj? toMongo(Type fantomType, Obj? fantomObj) {
		get(fantomType).toMongo(fantomType, fantomObj)
	}
	
	override Converter get(Type type) {
		// if a specific converter can't be found then embed a document
		typeLookup.findParent(type)
	}	
}
