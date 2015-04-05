using afIoc
using afIocConfig::Config
using afBson::ObjectId

** (Service) - Contribute your 'Converter' classes to this.
** 
** @uses a Configuration of 'Type:Converter' where 'Type' is what the 'Converter', um, converts to and from Mongo!
@NoDoc	// don't overwhelm the masses!
const class Converters {
	private const CachingTypeLookup	typeLookup
	
	new make(Type:Converter converters, |This|in) {
		in(this)
		this.typeLookup = CachingTypeLookup(converters)
	}

	** 'mongoObj' is nullable so converters can create empty lists and maps.
	Obj? toFantom(Type fantomType, Obj? mongoObj) {
		get(fantomType).toFantom(fantomType, mongoObj)
	}

	** 'fantomObj' is nullable so converters don't have to worry about it.
	Obj? toMongo(Obj? fantomObj) {
		(fantomObj == null) ? null : get(fantomObj.typeof).toMongo(fantomObj)
	}
	
	private Converter get(Type type) {
		// if a specific converter can't be found then embed a document
		typeLookup.findParent(type)
	}	
}
