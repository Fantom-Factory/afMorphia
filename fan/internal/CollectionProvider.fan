using afIoc
using afMongo

internal const class CollectionProvider : DependencyProvider {
	
	@Inject private const Registry registry
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(InjectionCtx injectionCtx) {
		injectionCtx.dependencyType.fits(Collection#) && !injectionCtx.fieldFacets.findType(Inject#).isEmpty
	}

	override Obj? provide(InjectionCtx injectionCtx) {
		type := ((Inject) injectionCtx.fieldFacets.findType(Inject#).first).type
		datastore := (Datastore) registry.autobuild(Datastore#, [type])
		return datastore.collection
	}

}
