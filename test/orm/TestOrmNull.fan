
internal class TestOrmNull : Test {
	
	Void testDocs() {
		user1 := BsonConverters().fromBsonDoc([:], T_User01#) as T_User01
		verifyEq(null, user1.name)
		
		// todo: at some point we may want to add some kind of "allowNull" property but need to investigate the effects of "undefined"
		user1 = BsonConverters().fromBsonDoc(["name":null], T_User01#) as T_User01
		verifyEq(null, user1.name)
		
		bson1 := BsonConverters(null, [
			"storeNullFields" : true
		]).toBsonDoc(user1)
		verifyEq(bson1, ["name":null])
	}
}

internal class T_User01 {
	@BsonProperty Str? name
	new make(|This|? f) { f(this) }
}
