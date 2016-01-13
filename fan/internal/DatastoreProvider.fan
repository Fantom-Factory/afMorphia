using afIoc

internal const class DatastoreProvider : DependencyProvider {
	
	new make(|This| in) { in(this) }
	
	override Bool canProvide(Scope scope, InjectionCtx ctx) {
		if (!ctx.isFieldInjection)
			return false

		if (!ctx.field.hasFacet(Inject#))
			return false

		if (!ctx.field.type.fits(Datastore#))
			return false

		return true
	}

	override Obj? provide(Scope scope, InjectionCtx ctx) {
		type := ((Inject) ctx.field.facet(Inject#)).type ?: throw Err("Field must define @Inject.type - ${ctx.field.qname}")
		return scope.build(Datastore#, [type])
	}
}
