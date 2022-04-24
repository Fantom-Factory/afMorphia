using afBson::ObjectId

internal class TestNullsInDb : MorphiaDbTest {
	
	Datastore?	ds
	
	override Void setup() {
		super.setup
		this.ds = Datastore(mc.connMgr, T_Entity25#)
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
	@BsonProp	ObjectId	_id	:= ObjectId() 
	@BsonProp	Int			_version 
	@BsonProp	Int?		int
	@BsonProp	Str?		str
	@BsonProp	Str[]?		list
	@BsonProp	[Str:Str]?	map

	new make(|This| in) { in(this) }
}