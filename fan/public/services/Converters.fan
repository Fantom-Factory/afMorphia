using afIoc
using afIocConfig::Config
using afBson::ObjectId

** (Service) - Contribute your 'Converter' classes to this.
** 
** @uses a MappedConfig of 'Type:Converter' where 'Type' is what the 'Converter', um, converts to and from Mongo!
@NoDoc	// don't overwhelm the masses!
const mixin Converters {
	
	** 'mongoObj' is nullable so converters can create empty lists and maps.
	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)
	
	** 'fantomObj' is nullable so converters don't have to worry about it.
	abstract Obj? toMongo(Obj? fantomObj)
	
}

internal const class ConvertersImpl : Converters {
	private const CachingTypeLookup	typeLookup
	
	@Inject @Config { id="afMorphia.documentConverter" }
	private const Converter documentConverter
	
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
		// if a converter can't be found then embed a document
		typeLookup.findParent(type, false) ?: documentConverter
	}	
}
