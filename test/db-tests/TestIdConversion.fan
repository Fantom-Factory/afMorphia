using afIoc::Inject

internal class TestIdConversion : MorphiaDbTest {

	@Inject { type=T_Entity19# } 
	Datastore?	ds

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
	@Property { name="_id" } Uri email
	@Property {} Str name 	
	
	new make(|This|in) { in(this) }
}
