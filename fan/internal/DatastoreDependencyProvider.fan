using afIoc

const class DatastoreDependencyProvider : DependencyProvider {
	
	@Inject private const Registry registry
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(InjectionCtx injectionCtx) {
		injectionCtx.dependencyType.fits(Datastore#) && !injectionCtx.fieldFacets.findType(Of#).isEmpty
	}

	override Obj? provide(InjectionCtx injectionCtx) {
		type := ((Of) injectionCtx.fieldFacets.findType(Of#).first).type
		return registry.autobuild(Datastore#, [type])
	}

}
