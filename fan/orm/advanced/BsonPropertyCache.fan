using afConcurrent::AtomicMap

@NoDoc
const class BsonPropertyCache {
	private const AtomicMap cache := AtomicMap()
	private const Bool serializableMode

	new make(Bool serializableMode := false) {
		this.serializableMode = serializableMode
	}

	** The main public method to return field props.
	** 
	** 'ctx' isn't used, but gives subclasses more context to adjust dynamically.
	virtual BsonPropertyData[] getOrFindProps(Type type, BsonConverterCtx? ctx := null) {
		// try get() first to avoid creating the func - method.func binding doesn't work in JS
		cache.get(type) ?: cache.getOrAdd(type) { findProps(type).toImmutable }
	}

	** An internal method that does the *actual* propery finding.
	virtual BsonPropertyData[] findProps(Type entityType) {
		// I dunno wot synthetic fields are but I'm guessing I dun-wan-dem!
		frops := entityType.fields.exclude { it.isStatic || it.isSynthetic }
		if (serializableMode == false)
			frops = frops.findAll { it.hasFacet(BsonProperty#) }
		else
			frops = frops.exclude { it.hasFacet(Transient#) }
		props := (BsonPropertyData[]) frops.map { makeBsonPropertyData(it) }
		names := props.map { it.name }.unique

		if (props.size != names.size) {
			fields := Str:Field[:]
			props.each {
				if (fields.containsKey(it.name))
					throw Err(msgDuplicatePropertyName(it.name, fields[it.name], it.field))
				fields.add(it.name, it.field)
			}
		}
		return props
	}

	** Clears the tag cache.
	virtual Void clear() {
		cache.clear
	}

	** Override hook for creating your own BsonPropertyData.
	virtual BsonPropertyData makeBsonPropertyData(Field field) {
		BsonPropertyData(field)
	}

	private static Str msgDuplicatePropertyName(Str name, Field field1, Field field2) {
		stripSys("Property name '${name}' is defined twice at '$field1.qname' and '${field2.qname}'")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
