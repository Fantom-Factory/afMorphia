using afIoc
using afMongo

internal class MorphiaDbTest : MorphiaTest {
	
	@Of { type=T_Entity01# } 
	@Inject Datastore?	ds
	@Inject Database?	db

	override Void setup() {
		super.setup
		db.collectionNames.each { db[it].drop }
	}

}
