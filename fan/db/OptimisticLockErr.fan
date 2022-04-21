
** Thrown when updating an entity and a newer _version exists.
const class OptimisticLockErr : Err {

	** The entity type being updated.
	const Type type

	** The out-of-date version number.
	const Int  version

	new make(Str msg, Type type, Int version) : super(msg, null) {
		this.type	 = type
		this.version = version
	}
}
