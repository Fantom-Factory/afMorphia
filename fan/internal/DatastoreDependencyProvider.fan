using afIoc

internal const class DatastoreDependencyProvider : DependencyProvider {
	
	@Inject private const Registry registry
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(InjectionCtx injectionCtx) {
		injectionCtx.dependencyType.fits(Datastore#) && !injectionCtx.fieldFacets.findType(TypeOf#).isEmpty
	}

	override Obj? provide(InjectionCtx injectionCtx) {
		type := ((TypeOf) injectionCtx.fieldFacets.findType(TypeOf#).first).type
		return registry.autobuild(Datastore#, [type])
	}

}
