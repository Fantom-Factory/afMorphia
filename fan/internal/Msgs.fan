
internal const mixin Msgs {

	static Str serializer_staticCtorIsNotStatic(Method ctor) {
		"Static ctor ${ctor.qname} is NOT static!"
	}

	static Str serializer_staticCtorIsNull(Method ctor, Field field, Str:Obj? document) {
		"Static ctor ${ctor.qname} returned null but field '${field.qname}' is NOT nullable : ${document}"
	}

	static Str serializer_staticCtorNotFitField(Method ctor, Type valType, Field field, Str:Obj? document) {
		"Static ctor ${ctor.qname} returned a '${valType.signature}' but it does not fit field '${field.qname}' of type '${field.type.signature}' : ${document}"
	}

	static Str serializer_propertyNotFound(Field field, Str:Obj? document) {
		"MongoDB document does not contain a property for field ${field.qname} : ${document}"
	}

	static Str serializer_propertyIsNull(Str propName, Field field, Str:Obj? document) {
		"MongoDB document property '${propName}' is null but field '${field.qname}' is NOT nullable : ${document}"
	}

	static Str serializer_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
		"MongoDB document property '${propName}' of type '${propType.signature}' does not fit field '${field.qname}' of type '${field.type.signature}' : ${document}"
	}

	static Str serializer_ctorNotFitField(Type implType, Field field, Str:Obj? document) {
		"Type '${implType.signature}' does not fit field '${field.qname}' of type '${field.type.signature}' : ${document}"
	}

	static Str serializer_ctorIsNotCtor(Method ctor) {
		"Method '${ctor.qname}' is NOT a ctor!"
	}

	static Str serializer_ctorIsStatic(Method ctor) {
		"Ctor '${ctor.qname}' is static!"
	}

	static Str serializer_notMongoLiteral(Type mongoType, Field field) {
		"Type '${mongoType.signature}' is NOT a MongoDB literal. It was converted from ${field.qname}"
	}

}
