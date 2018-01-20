
** As thrown by Morphia.
const class MorphiaErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) { }
}

** Thrown by 'Datastore.update()' when it tried to update an entity when newer data exists.
const class OptimisticLockErr : MorphiaErr {

	** The entity type being updated.
	const Type type

	** The out-of-date version number.
	const Int  version

	new make(Str msg, Type type, Int version) : super(msg, null) {
		this.type	 = type
		this.version = version
	}
}
