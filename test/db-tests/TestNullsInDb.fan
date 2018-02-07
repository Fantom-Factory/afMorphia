using afIoc::Inject
using afBson::ObjectId

internal class TestNullsInDb : MorphiaDbTest {
	
	@Inject { type=T_Entity25# } 
	Datastore?	ds
	
	override Void setup() {
		super.setup
		ds.drop
	}
	
	Void testNull() {
		
		// just check that nulls do get written out to database
		
		ent := T_Entity25{}
		id  := ent._id
		ds.insert(ent)

		verifyAllNull(id)
		
		ent.int = 25
		ds.update(ent)
		ent = ds.get(id)
		verifyEq(ent.int, 25)
		ent.int = null
		ds.update(ent)
		ent = ds.get(id)
		verifyAllNull(id)

		ent.str = "wotever"
		ds.update(ent)
		ent = ds.get(id)
		verifyEq(ent.str, "wotever")
		ent.str = null
		ds.update(ent)
		verifyAllNull(id)

		ent.list = ["wotever"]
		ds.update(ent)
		ent = ds.get(id)
		verifyEq(ent.list, ["wotever"])
		ent.list = null
		ds.update(ent)
		verifyAllNull(id)

		ent.map = ["wot":"ever"]
		ds.update(ent)
		ent = ds.get(id)
		verifyEq(ent.map, ["wot":"ever"])
		ent.map = null
		ds.update(ent)
		verifyAllNull(id)
	}	
	
	Void verifyAllNull(ObjectId id) {
		data := ds.collection.get(id)
		verifyEq(data.size, 2)
		verifyEq(data["_id"], id)
		verifyNotNull(data["_version"])
	}
}

@Entity
internal class T_Entity25 {
	@Property	ObjectId	_id	:= ObjectId() 
	@Property	Int			_version 
	@Property	Int?		int
	@Property	Str?		str
	@Property	Str[]?		list
	@Property	[Str:Str]?	map

	@Inject
	new make(|This| in) { in(this) }
}