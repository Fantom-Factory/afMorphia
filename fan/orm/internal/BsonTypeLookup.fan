using afBeanUtils::TypeLookup
using afConcurrent::AtomicMap

** A 'TypeLookup' that caches the lookup results.
internal const class BsonTypeLookup : TypeLookup {
	private const AtomicMap parentCache   := AtomicMap()
	private const AtomicMap childrenCache := AtomicMap()

	new make(Type:Obj? values) : super(values) { }
	
	** Cache the lookup results
	override Obj? findParent(Type type, Bool checked := true) {
		nonNullable := type.toNonNullable
		// try get() first to avoid creating the func - method.func binding doesn't work in JS
		return parentCache.containsKey(nonNullable)
			? parentCache.get(nonNullable)
			: parentCache.getOrAdd(nonNullable) { doFindParent(nonNullable, checked) } 
	}
	
	** Cache the lookup results
	override Obj?[] findChildren(Type type, Bool checked := true) {
		nonNullable := type.toNonNullable
		// try get() first to avoid creating the func - method.func binding doesn't work in JS
		return childrenCache.containsKey(nonNullable)
			? childrenCache.get(nonNullable)
			: childrenCache.getOrAdd(nonNullable) { doFindChildren(nonNullable, checked) } 
	}

	** Clears the lookup cache 
	Void clear() {
		parentCache.clear
		childrenCache.clear
	}
}