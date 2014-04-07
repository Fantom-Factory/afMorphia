
internal const mixin Msgs {
	
	static Str serializer_propertyNotFound(Field field, Str:Obj? document) {
		"MongoDB document does not contain a property for field ${field.qname} : ${document}"
	}
	
	static Str serializer_propertyIsNull(Str propName, Field field, Str:Obj? document) {
		"MongoDB document property '${propName}' is null but field '${field.qname}' is NOT nullable : ${document}"
	}

	static Str serializer_propertyDoesNotFitField(Str propName, Type propType, Field field, Str:Obj? document) {
		"MongoDB document property '${propName}' of type '${propType.signature}' does not fit field '${field.qname}' of type '${field.type.signature}' : ${document}"
	}
	
}
