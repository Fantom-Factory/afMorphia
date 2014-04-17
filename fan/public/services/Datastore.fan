using afMongo

const class Datastore {
	
	private const Type			collectionType
	private const Collection 	collection
	
	new make(Type collectionType, DB db) {
		this.collectionType	= collectionType
		this.collection		= db.collection(collectionType.name)
	}
	
	Obj? find(Type collectionType, Obj id) {
		collection.findOne
	}

	Obj[] listAll(Type collectionType) {
		collection.find.toList
	}
	
//	save
	
//	update
	
//	delete
}
