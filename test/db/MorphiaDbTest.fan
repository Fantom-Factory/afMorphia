using afMongo::MongoConnMgr

internal class MorphiaDbTest : Test {
	
	Morphia?		morphia
	
	override Void setup() {
		mongoUrl	:= `mongodb://localhost:27017/afMorphiaTest`
		morphia		= Morphia(mongoUrl)
		// not dropping the DB makes the test x10 faster!
		// but you can't delete from a capped collection!
		morphia.db.listCollectionNames.each { morphia.db[it].drop }
		Pod.of(this).log.level = LogLevel.warn
	}

	override Void teardown() {
		morphia?.shutdown
	}
}
