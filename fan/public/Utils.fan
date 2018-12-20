
@NoDoc	// this class may change name later - maybe move to @Property itself?
const mixin Utils {
	
	static Str entityName(Type entityType) {
		entity	:= (Entity?) entityType.facet(Entity#, false)
				?: throw ArgErr(ErrMsgs.datastore_entityFacetNotFound(entityType))
		return entity?.name ?: entityType.name
	}

	@Deprecated
	static Str propertyName(Field propertyField) {
		property := (Property?) propertyField.facet(Property#, false)
		return property?.name ?: propertyField.name
	}

	@Deprecated
	static Type propertyType(Field propertyField) {
		property := (Property?) propertyField.facet(Property#, false)
		return property?.implType ?: propertyField.type
	}

	@Deprecated
	static Obj? propertyDefVal(Field propertyField) {
		property := (Property?) propertyField.facet(Property#, false)
		return property?.defVal
	}
	
	static Str objToPropertyName(Obj name) {
		fieldName := null as Str

		if (name is Field) {
			// we can't check if the field belongs to an entity (think nested objects)
			// and if the user overrides ObjConverter.findPropertyFields() then it need not been annotated with @Property either
			property := (Property?) ((Field) name).facet(Property#, false)
			fieldName = property?.name ?: ((Field) name).name
		} else

		if (name is Str)
			fieldName = name

		if (fieldName == null)
			throw ArgErr(ErrMsgs.query_unknownField(name))
		
		return fieldName
	}
}
