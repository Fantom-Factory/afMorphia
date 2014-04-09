using afIoc
using afMongo::ObjectId

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
	private const StrategyRegistry 	converterStrategy
	
	private const Converter documentConverter
	
	new make(Type:Converter converters, Registry registry) {
		this.converterStrategy = StrategyRegistry(converters)
		this.documentConverter = registry.createProxy(Converter#, DocumentConverter#)
	}

	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		get(fantomType).toFantom(fantomType, mongoObj)
	}

	override Obj? toMongo(Obj? fantomObj) {
		(fantomObj == null) ? null : get(fantomObj.typeof).toMongo(fantomObj)
	}
	
	private Converter get(Type type) {
		converterStrategy.findBestFit(type, false) ?: documentConverter
	}	
}
