
internal class TestOrmNull : Test {
	
	Void testDocs() {
		user1 := BsonConvs().fromBsonDoc([:], T_User01#) as T_User01
		verifyEq(null, user1.name)
		
		// todo: at some point we may want to add some kind of "allowNull" property but need to investigate the effects of "undefined"
		user1 = BsonConvs().fromBsonDoc(["name":null], T_User01#) as T_User01
		verifyEq(null, user1.name)
		
		bson1 := BsonConvs(null, [
			"storeNullFields" : true
		]).toBsonDoc(user1)
		verifyEq(bson1, ["name":null])
	}
}

internal class T_User01 {
	@BsonProp Str? name
	new make(|This|? f) { f(this) }
}
