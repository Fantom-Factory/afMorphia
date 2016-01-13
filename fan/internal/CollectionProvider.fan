using afIoc
using afMongo

internal const class CollectionProvider : DependencyProvider {
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(Scope scope, InjectionCtx ctx) {
		if (!ctx.isFieldInjection)
			return false

		if (!ctx.field.hasFacet(Inject#))
			return false

		if (!ctx.field.type.fits(Collection#))
			return false

		return true
	}

	override Obj? provide(Scope scope, InjectionCtx ctx) {
		type := ((Inject) ctx.field.facet(Inject#)).type ?: throw Err("Field must define @Inject.type - ${ctx.field.qname}")
		datastore := (Datastore) scope.build(Datastore#, [type])
		return datastore.collection
	}	
}
