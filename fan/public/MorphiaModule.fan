using afIoc

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
const class MorphiaModule {

	static Void bind(ServiceBinder binder) {
		binder.bind(MorphiaService#)
	}

	@Contribute { serviceType=RegistryStartup# }
	static Void contributeToStartup(OrderedConfig config, MorphiaService service) {
		config.add |->| {
			// do stuff on application startup
		}
	}
}
