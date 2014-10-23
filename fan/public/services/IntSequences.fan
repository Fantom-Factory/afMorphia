using afIoc
using afIocConfig
using afMongo

** (Service) - 
** A small utility class that creates sequential sequences of 'Ints' as an alternative to using 
** BSON 'ObjectIds'.
** 
** It works by creating MongoDB collection (called 'IntSequences' by default) where it stores the 
** last ID for an entity to be used. When a new ID is requested an atomic *findAndUpdate* operation
** is run on the collection to both increment and return the relevant document.
** 
** By keeping the last IDs stored in the database it ensures the IDs are persisted between system 
** restarts and that multiple clients can generate unique IDs.
** 
** While there is an overhead in generating new IDs, 'Int' IDs have the advantage of using less 
** space in indexes, being easier to work with in web applications and they're generally nicer to
** look at! 
const mixin IntSequences {
	
	** The name of MongoDB collection to be used.
	abstract Str collectionName()
	
	** Returns the next 'Int' for the given sequence name. 
	abstract Int nextInt(Str seqName)

	** Returns the next 'Int' for the given entity. 
	** The sequence name is derived from the class name and '@Entity' facet. 
	** 
	** Throws 'ArgErr' if the given type does not have the '@Entity' facet.
	abstract Int nextId(Type entityType)
	
	** Resets the last ID to zero.
	abstract Void reset(Str seqName)

	** Resets *all* the last IDs to zero.
	abstract Void resetAll(Str seqName)

	** Delete the 'IntSequences' collection.
	** Safe operation, does not throw Err if the collection does not exist.
	abstract Void drop()
}

internal const class IntSequencesImpl : IntSequences {
	
	@Config { id="afMorphia.intSequencesCollectionName" }
	@Inject override const Str collectionName
	
	private const Collection intSeqCol
	
	new make(Database database, |This|in) {
		in(this)
		intSeqCol = database[collectionName]
	}

	override Int nextId(Type entityType) {
		entity  := (Entity?) Type#.method("facet").callOn(entityType, [Entity#, false])
				?: throw ArgErr(ErrMsgs.datastore_entityFacetNotFound(entityType))		
		name := entity.name ?: entityType.name
		return nextInt(name)
	}

	override Int nextInt(Str seqName) {
		doc := intSeqCol.findAndUpdate(["_id":seqName], ["\$inc":["lastId":1]], true)
		
		if (doc == null) {
			doc = ["_id":seqName, "lastId":1]
			intSeqCol.insert(doc)
		}
		
		return doc["lastId"]
	}
	
	override Void reset(Str seqName) {
		intSeqCol.update(["_id":seqName], ["lastId":0])
	}

	override Void resetAll(Str seqName) {
		intSeqCol.update([:], ["lastId":0], true)
	}

	override Void drop() {
		intSeqCol.drop(false)
	}
}
