using afIoc
using afIocConfig

abstract internal class MorphiaTest : Test {

	Scope? scope
	
	override Void setup() {
		scope = RegistryBuilder().addModulesFromPod("afMorphia").addModule(T_MorphiaTestModule#).build.rootScope
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
