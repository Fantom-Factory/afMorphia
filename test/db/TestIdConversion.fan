
internal class TestIdConversion : MorphiaDbTest {

	Datastore?	ds
	
	override Void setup() {
		super.setup
		this.ds = Datastore(mc.connMgr, T_Entity19#)
	}

	Void testIdConversion() {
		micky := T_Entity19 { 
			it.email	= `micky.mouse@disney.com`
			it.name		= "Micky Mouse"
		}
		ds.insert(micky)

		// test get
		mouse := (T_Entity19?) ds.get(`micky.mouse@disney.com`)
		verifyEq(mouse.email, `micky.mouse@disney.com`)
		verifyEq(mouse.name, "Micky Mouse")

		// test update
		mouse.name = "FooBar"
		ds.update(mouse)
		mouse = (T_Entity19?) ds.get(`micky.mouse@disney.com`)
		verifyEq(mouse.email, `micky.mouse@disney.com`)
		verifyEq(mouse.name, "FooBar")

		// test deleteById
		ds.deleteById(mouse.email)
		mouse = ds.get(`micky.mouse@disney.com`, false)
		verifyNull(mouse)
	}
}

@Entity 
internal class T_Entity19 {
	@BsonProp { name="_id" } Uri email
	@BsonProp {} Str name 	
	
	new make(|This|in) { in(this) }
}
