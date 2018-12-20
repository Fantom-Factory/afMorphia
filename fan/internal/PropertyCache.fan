using afConcurrent::AtomicMap

@NoDoc	// advanced use only
const class PropertyCache {
	private const AtomicMap cache := AtomicMap()

	virtual PropertyData[] getOrFindProperties(Type entityType) {
		cache.getOrAdd(entityType) |->PropertyData[]| {
			props := (PropertyData[]) entityType.fields.findAll { it.hasFacet(Property#) }.map { PropertyData(it) }
			names := props.map { it.name }.unique

			if (props.size != names.size) {
				fields := Str:Field[:]
				props.each {
					if (fields.containsKey(it.name))
						throw MorphiaErr(ErrMsgs.datastore_duplicatePropertyName(it.name, fields[it.name], it.field))
					fields.add(it.name, it.field)
				}
			}
			return props
		}
	}

	** Clears the property cache. 
	virtual Void clear() {
		cache.clear
	}
}
