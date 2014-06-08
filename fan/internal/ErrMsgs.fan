
internal const mixin ErrMsgs {

	static Str documentConv_propertyNotFound(Field field, Str:Obj? document) {
		stripSys("MongoDB document does not contain a property for field ${field.qname} : ${document}")
	}

	static Str documentConv_propertyIsNull(Str propName, Field field, Str:Obj? document) {
		stripSys("MongoDB document property '${propName}' is null but field ${field.qname} is NOT nullable : ${document}")
	}

	static Str documentConv_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
		stripSys("MongoDB document property '${propName}' of type '${propType.signature}' does not fit field ${field.qname} of type '${field.type.signature}' : ${document}")
	}

	static Str documentConv_noConverter(Type fantomType, Obj mongoObj) {
		stripSys("Could not find a Converter to ${fantomType.qname} from '${mongoObj.typeof.qname} - ${mongoObj}'")
	}

	static Str mapConverter_cannotCoerceKey(Type keyType) {
		stripSys("Unsupported Map key type '${keyType.qname}', cannot coerce from Str#. See 'afIoc::TypeCoercer' for details.")
	}

	static Str datastore_entityFacetNotFound(Type entityType) {
		stripSys("Entity type ${entityType.qname} does NOT have the @${Entity#.name} facet.")
	}

	static Str datastore_entityNotFound(Type entityType, Obj id) {
		stripSys("Could not find entity ${entityType.qname} with Id: ${id}")
	}

	static Str datastore_idFieldNotFound(Type entityType) {
		stripSys("Could not find property named '_id' on ${entityType.qname}.")
	}

	static Str datastore_idDoesNotFit(Obj id, Field idField) {
		stripSys("Given ID does not fit ${idField.qname} ${idField.type.signature}# - ${id.typeof.signature} ${id}")
	}

	static Str datastore_entityWrongType(Type entityType, Type dsType) {
		stripSys("Given Entity of type ${entityType.qname} does not fit Datastore type ${dsType.qname}")
	}

	static Str datastore_facetTypeDoesNotFitField(Type facetType, Field field) {
		stripSys("Property Facet type '${facetType.signature}' does not fit field type '${field.qname} ${field.signature}'")
	}

	static Str datastore_duplicatePropertyName(Str name, Field field1, Field field2) {
		stripSys("Property name '${name}' is defined twice at '$field1.qname' and '${field2.qname}'")
	}

	static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
