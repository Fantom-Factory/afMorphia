
internal const class SlotConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return Slot.find((Str) mongoObj)
	}
	
	override Obj? toMongo(Obj fantomObj) {
		((Slot) fantomObj).qname
	}

}
