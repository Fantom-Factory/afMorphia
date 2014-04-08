using afIoc::ConcurrentState
using afIoc::StrategyRegistry
using afIoc::TypeCoercer

** (Service) - Contribute your 'Converter' classes to this.
** 
** @uses a MappedConfig of 'Type:Converter' where 'Type' is what the 'Converter', um, converts to and from Mongo!
@NoDoc	// don't overwhelm the masses!
const mixin Converters { 
	@Operator
	abstract internal Converter? get(Type type)
}

internal const class ConvertersImpl : Converters {
	private const StrategyRegistry 	converterStrategy
	
	internal new make(Type:Converter converters) {
		this.converterStrategy = StrategyRegistry(converters)
	}

	override Converter? get(Type type) {
		converterStrategy.findBestFit(type, false)
	}
}
