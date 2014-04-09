using afIoc
using afMongo::ObjectId

** (Service) - Contribute your 'Converter' classes to this.
** 
** @uses a MappedConfig of 'Type:Converter' where 'Type' is what the 'Converter', um, converts to and from Mongo!
@NoDoc	// don't overwhelm the masses!
const mixin Converters {
	
	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)
	
	abstract Obj? toMongo(Type fantomType, Obj? fantomObj)
	
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
	
	override Obj? toMongo(Type fantomType, Obj? fantomObj) {
		get(fantomType).toMongo(fantomType, fantomObj)
	}
	
	private Converter get(Type type) {
		converterStrategy.findBestFit(type, false) ?: documentConverter
	}	
}
