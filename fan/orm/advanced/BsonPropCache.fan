using afConcurrent::AtomicMap

@NoDoc	// Advanced use only
const class BsonPropCache {
	private const AtomicMap cache := AtomicMap()

	** The main public method to return field props.
	** 
	** 'ctx' is used to , but gives subclasses more context to adjust dynamically.
	virtual BsonPropData[] getOrFindProps(Type type, BsonConvCtx? ctx := null) {
		// try get() first to avoid creating the func - method.func binding doesn't work in JS
		cache.get(type) ?: cache.getOrAdd(type) { findProps(type, ctx).toImmutable }
	}

	** An internal method that does the *actual* property finding.
	virtual BsonPropData[] findProps(Type entityType, BsonConvCtx? ctx := null) {
		// I dunno wot synthetic fields are but I'm guessing I dun-wan-dem!
		frops := entityType.fields.exclude { it.isStatic || it.isSynthetic }
		
		// todo should we be caching fields from pickled objs?
		// hmm... I can't think of a reason not to!?
		if (ctx?.optPickleMode == true)
			frops = frops.exclude { it.hasFacet(Transient#) }
		else
			frops = filterFields(frops)

		props := (BsonPropData[]) frops.map { makeBsonPropData(it) }
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
	
	** Return just the fields we're interested in converting.
	** 
	** *Is not called during pickle mode - if needed, just override findProps() instead.*
	virtual Field[] filterFields(Field[] fields) {
		fields.findAll { it.hasFacet(BsonProp#) }
	}

	** Clears the tag cache.
	virtual Void clear() {
		cache.clear
	}

	** Override hook for creating your own BsonPropData.
	virtual BsonPropData makeBsonPropData(Field field) {
		BsonPropData(field)
	}

	private static Str msgDuplicatePropertyName(Str name, Field field1, Field field2) {
		stripSys("Property name '${name}' is defined twice at '$field1.qname' and '${field2.qname}'")
	}

	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
