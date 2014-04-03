using afIoc::Inject
using afIoc::Registry

const class MorphiaService {
	
	@Inject	private const Registry registry
	
	new make(|This|in) { in(this) }
	
}
