using afMongo::MongoClient
using afMongo::MongoDb

internal class MorphiaDbTest : Test {
	
	MongoClient? mc
	MongoDb?	 db
	
	override Void setup() {
		mongoUri	:= `mongodb://localhost:27017/afMorphiaTest`
		mc = MongoClient(mongoUri)
		db = mc.db
		// not dropping the DB makes the test x10 faster!
		// but you can't delete from a capped collection!
		db.listCollectionNames.each { db[it].drop }
		Pod.of(this).log.level = LogLevel.warn
	}

	override Void teardown() {
		mc?.shutdown
	}
}
