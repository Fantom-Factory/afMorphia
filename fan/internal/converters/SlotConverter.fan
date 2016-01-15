
internal const class SlotConverter : Converter {

	override Obj? toFantom(Type type, Obj? mongoObj) {
		if (mongoObj == null) return null
		return Slot.find((Str) mongoObj)
	}
	
	override Obj? toMongo(Type type, Obj? fantomObj) {
		if (fantomObj == null) return null
		return ((Slot) fantomObj).qname
	}

}
