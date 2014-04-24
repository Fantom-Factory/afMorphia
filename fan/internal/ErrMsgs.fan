
internal const mixin ErrMsgs {

	static Str documentConv_propertyNotFound(Field field, Str:Obj? document) {
		"MongoDB document does not contain a property for field ${field.qname} : ${document}"
	}

	static Str documentConv_propertyIsNull(Str propName, Field field, Str:Obj? document) {
		"MongoDB document property '${propName}' is null but field ${field.qname} is NOT nullable : ${document}"
	}

	static Str documentConv_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
		"MongoDB document property '${propName}' of type '${propType.signature}' does not fit field ${field.qname} of type '${field.type.signature}' : ${document}"
	}

	static Str documentConv_noConverter(Type fantomType, Obj mongoObj) {
		"Could not find a Converter to ${fantomType.qname} from '${mongoObj.typeof.qname} - ${mongoObj}'"
	}

	static Str mapConverter_cannotCoerceKey(Type keyType) {
		"Unsupported Map key type '${keyType.qname}', cannot coerce from Str#. See 'afIoc::TypeCoercer' for details."
	}

}
