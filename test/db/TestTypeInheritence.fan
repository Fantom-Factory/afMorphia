
internal class TestTypeInheritence : MorphiaDbTest {
	
	Datastore?	ds
	
	override Void setup() {
		super.setup
		this.ds = morphia[T_Entity21#]
	}

	Void testIdConversion() {
		ent := T_Entity21 { 
			it._id	= 3
			it.ents	= [
				T_Entity22Impl1 { field1 = "Judge" },
				T_Entity22Impl2 { field2 = "Dredd" },
			]
		}
		ds.insert(ent)

		// test get
		ents := (T_Entity21) ds.get(3)
		verifyType(ents.ents[0], T_Entity22Impl1#)
		verifyType(ents.ents[1], T_Entity22Impl2#)
		verifyEq(ents.ents[0]->field1, "Judge")
		verifyEq(ents.ents[1]->field2, "Dredd")
	}
}


@Entity 
internal class T_Entity21 {
	@BsonProp Int			_id
	@BsonProp T_Entity22[]	ents

	new make(|This|in) { in(this) }
}

internal abstract class T_Entity22 {
	@BsonProp	Type	_type	:= typeof
}
internal class T_Entity22Impl1 : T_Entity22 {
	@BsonProp Str? field1
}

internal class T_Entity22Impl2 : T_Entity22 {
	@BsonProp Str? field2
}
