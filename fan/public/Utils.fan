
@NoDoc	// this class may change name later - maybe move to @Property itself?
const mixin Utils {
	
	static Str entityName(Type entityType) {
		entity	:= (Entity?) entityType.facet(Entity#, false)
				?: throw ArgErr(ErrMsgs.datastore_entityFacetNotFound(entityType))
		return entity?.name ?: entityType.name
	}

	static Str propertyName(Field propertyField) {
		property := (Property?) propertyField.facet(Property#, false)
		return property?.name ?: propertyField.name
	}

	static Type propertyType(Field propertyField) {
		property := (Property?) propertyField.facet(Property#, false)
		return property?.implType ?: propertyField.type
	}
}
