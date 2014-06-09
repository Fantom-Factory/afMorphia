using afIoc
using afIocConfig

abstract internal class MorphiaTest : Test {

	Registry? reg
	
	override Void setup() {
		reg = RegistryBuilder().addModules([MorphiaModule#, IocConfigModule#, T_MorphiaTestModule#]).build.startup
		reg.injectIntoFields(this)
	}
	
	override Void teardown() {
		reg?.shutdown
	}

	Void verifyMorphiaErrMsg(Str errMsg, |Obj| func) {
		verifyErrMsg(MorphiaErr#, errMsg, func)
	}

	protected Void verifyErrMsg(Type errType, Str errMsg, |Obj| func) {
		try {
			func(4)
		} catch (Err e) {
			if (!e.typeof.fits(errType)) 
				throw Err("Expected $errType got $e.typeof", e)
			verifyEq(errMsg, e.msg)	// this gives the Str comparator in eclipse
			return
		}
		throw Err("$errType not thrown")
	}
}

internal const class T_MorphiaTestModule {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(MappedConfig config) {
		config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/afMorphiaTest`
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig config) {
		config.remove("MorphiaStartup")
	}
}