
const class EnumConverter : Converter {

	override Obj? toFantom(Field field, Obj? obj) {
		field.type.method("fromStr").call(obj, true)
//		Env.cur.err.printLine(obj)
//		Env.cur.err.printLine(obj.typeof)
//		m:=field.type.method("fromStr")
//		Env.cur.err.printLine(m)
//		Env.cur.err.printLine(m.signature)
//		return m.call(obj, true)
	}
	
	override Obj? toMongo(Field field, Obj? obj) {
		(obj as Enum)?.name
	}

}
