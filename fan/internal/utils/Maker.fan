
class Maker {
	Type type
	
	Field:Obj? vals	:= [:]
//	private Field:Obj? vals	:= [:]

	new makeFromType(Type type) {
		this.type = type
	}

	** Fantom Bug: http://fantom.org/sidewalk/topic/2163#c13978
	@Operator 
	private Obj? get(Field field) {
		vals[field]
	}

	@Operator
	This set(Field field, Obj? val) {
		vals[field] = val
		return this
	}
	
	Obj make() {
		type.make([Field.makeSetFunc(vals)])
	}
}
