using afIoc::Inject
using afMongo::Database

internal class MorphiaDbTest : MorphiaTest {
	
	@Inject Database?	db

	override Void setup() {
		super.setup
		db.collectionNames.each { db[it].drop }
	}

}
