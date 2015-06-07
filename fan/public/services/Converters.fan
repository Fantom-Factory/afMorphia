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
	** 'mongoObj' is nullable so converters can create empty lists and maps.
	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)

	** Converts the given Fantom object to its Mongo representation.
	** 
	** If 'null' is passed in, then 'null' is returned.
	abstract Obj? toMongo(Obj? fantomObj)
	
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

	override Obj? toMongo(Obj? fantomObj) {
		(fantomObj == null) ? null : get(fantomObj.typeof).toMongo(fantomObj)
	}
	
	private Converter get(Type type) {
		// if a specific converter can't be found then embed a document
		typeLookup.findParent(type)
	}	
}
