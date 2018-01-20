using afIoc::Inject

internal class TestDodgyKeys : MorphiaDbTest {
	
	@Inject { type=T_Entity20# } 
	Datastore?	ds

	Void testDodgyMapKeys() {		
		podData := T_Entity20 { 
			it._id	= 5
			it.meta = ["pod.name" : "FormBean"]
		}
		
		// inserting always worked as inserts aren't analysed by MongoDB
		ds.insert(podData)
		podData = ds.findAll.first
		verifyEq(podData.meta["pod.name"], "FormBean")
		
		// updating a altered document always dies with:
		// errmsg:The dotted field 'pod.name' in 'meta.pod.name' is not valid for storage.
		// see http://docs.mongodb.org/manual/faq/developers/#faq-dollar-sign-escaping
		podData.meta["pod.name"] = "FormBeanBozo"
		ds.update(podData)
		podData = ds.findAll.first
		verifyEq(podData.meta["pod.name"], "FormBeanBozo")
		
		ds.delete(podData)
		ds.drop
	}
}

@Entity 
internal class T_Entity20 {
	@Property {} Int		_id
	@Property {} Str:Str	meta
	new make(|This|in) { in(this) }
}
