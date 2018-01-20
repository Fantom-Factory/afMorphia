using afIoc::Inject
using afIoc::IocErr
using afBson::ObjectId

internal class TestOptimisticLocking : MorphiaDbTest {
	
	@Inject { type=T_Entity23# } 
	Datastore?	ds

//	Void testVersionIsInt() {
//		verifyErrMsg(IocErr#, "_version field must be of type Int - afMorphia::T_Entity24._version -> afBson::ObjectId") {
//			scope.build(Datastore#, [T_Entity24#])
//		}
//	}
	
	Void testUpdate() {
		ent := T_Entity23 { 
			it.data = "Hello"
		}
		
		// upsert the first time
		ds.update(ent, true)
		
		// if we change the data then mongo updates the obj
		ent.data = "Hello Mum!"
		ds.update(ent)
		
		// if we don't change the data, then mongo DOESN'T update the obj
		ds.update(ent)
		
		// if we can't find the ent, then throw an err
		ent._id = 2
		verifyErrMsg(MorphiaErr#, "Could not find entity afMorphia::T_Entity23 with ID: 2") {
			ds.update(ent)
		}
	}
	
	Void testOptimisticLocking() {		
		ds.insert(T_Entity23 { 
			it.data = "Hello"
		})

		ent1 := ds.get(1) as T_Entity23
		ent2 := ds.get(1) as T_Entity23
		
		ent1.data = "Hello Dude!"
		ds.update(ent1)
		
		ent2.data = "Argh! Concurrent Modification"
		verifyErrMsg(OptimisticLockErr#, "A newer version of afMorphia::T_Entity23 already exists, with ID 1") {
			ds.update(ent2)
		}
	}
}

@Entity
internal class T_Entity23 {
	@Property	Int		_id	:= 1
	@Property	Int		_version
	@Property	Str?	data
}

@Entity
internal class T_Entity24 {
	@Property	Int			_id	:= 1
	@Property	ObjectId	_version	// ERROR! should be an Int
	@Property	Str?		data
	new make(|This| f) { f(this) }
}