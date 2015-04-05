using afIoc

internal const class DatastoreProvider : DependencyProvider {
	
	@Inject private const Registry registry
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(InjectionCtx injectionCtx) {
		injectionCtx.dependencyType.fits(Datastore#) && !injectionCtx.fieldFacets.findType(Inject#).isEmpty
	}

	override Obj? provide(InjectionCtx injectionCtx) {
		type := ((Inject) injectionCtx.fieldFacets.findType(Inject#).first).type
		return registry.autobuild(Datastore#, [type])
	}

}
