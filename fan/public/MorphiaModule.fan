using afIoc

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
const class MorphiaModule {

	static Void bind(ServiceBinder binder) {
		binder.bind(Serializer#)
		binder.bind(Converters#).withoutProxy
	}
	
	@Contribute { serviceType=Converters# }
	static Void contributeConverters(MappedConfig config) {
		config[Enum#]		= config.autobuild(EnumConverter#)
	}
}
