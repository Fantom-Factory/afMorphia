using afIoc

internal class TestDatastoreDb : MorphiaDbTest {
	
	@TypeOf { type=T_Entity14# } 
	@Inject Datastore?	ds

	Void testBasicDatastore() {
		
	}

}

@Entity 
internal class T_Entity14 {
	@Property Int _id 
	@Property Str name 	
	@Property Uri email
	@Property Int age
	
	new make(|This|in) { in(this) }
}
