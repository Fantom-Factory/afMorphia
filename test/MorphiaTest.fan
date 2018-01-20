using afIoc::RegistryBuilder
using afIoc::Scope
using afIoc::Contribute
using afIoc::Configuration
using afIocConfig::ApplicationDefaults

abstract internal class MorphiaTest : Test {

	Scope? scope
	
	override Void setup() {
		scope = RegistryBuilder() { it.suppressLogging = true }
			.addModulesFromPod("afMorphia")
			.addModule(T_MorphiaTestModule#)
			.onRegistryStartup |Configuration config| {
				config.remove("afIoc.logServices")
				config.remove("afIoc.logBanner")
				config.remove("afIoc.logStartupTimes")
			}
			.onRegistryShutdown |Configuration config| {
				config.remove("afIoc.sayGoodbye")
			}
			.build
			.rootScope
		scope.inject(this)
	}
	
	override Void teardown() {
		scope?.registry?.shutdown
	}

	Void verifyMorphiaErrMsg(Str errMsg, |Obj| func) {
		verifyErrMsg(MorphiaErr#, errMsg, func)
	}
}

internal const class T_MorphiaTestModule {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(Configuration config) {
		config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/afMorphiaTest`
	}
	
	internal static Void onRegistryStartup(Configuration config) {
		config.remove("afMorphia.testConnection")
	}
}
