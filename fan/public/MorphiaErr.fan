
** As thrown by Morphia.
const class MorphiaErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) { }
}