
internal class TestDatastoreDb : MorphiaDbTest {
	
	Datastore?	ds
	
	override Void setup() {
		super.setup
		this.ds = morphia[T_Entity14#]
	}

	Void testBasicDatastore() {		
		micky := T_Entity14 { 
			it._id 		= 1 
			it.name		= "Micky Mouse"
			it.email	= `micky.mouse@disney.com`
			it.age		= 42
		}
		
		minny := T_Entity14 { 
			it._id 		= 2
			it.name		= "Minny Mouse"
			it.email	= `minny.mouse@disney.com`
			it.age		= 36
		}
		
		verifyEq(ds.exists, false)
		
		ds.insert(micky)
		verifyEq(ds.exists, true)
		verifyEq(ds.size, 1)
		
		ds.insert(minny)
		verifyEq(ds.exists, true)
		verifyEq(ds.size, 2)
		
		ent1 := (T_Entity14) ds.findOne(true) { eq("name", "Micky Mouse") }
		verifyEq(ent1.name, 	"Micky Mouse")
		verifyEq(ent1.email,	`micky.mouse@disney.com`)
		verifyEq(ent1.age, 		42)

		verifyEq(ds.count { it->age = 36 }, 1)

		ents := ds.find(["age":36]).toList
		verifyEq(ents.size, 	1)
		ent2 := (T_Entity14) ents.first
		verifyEq(ent2.name, 	"Minny Mouse")
		verifyEq(ent2.email,	`minny.mouse@disney.com`)
		verifyEq(ent2.age, 		36)

		ent2.age = 34
		ds.update(ent2)
		verifyEq(ds.count{ it->age = 36 }, 	0)
		verifyEq(ds.count{ it->age = 34 }, 	1)

		verifyEq(ds.findAll.size,	2)

		ent3 := (T_Entity14) ds.get(2)
		verifyEq(ent3.name, 	"Minny Mouse")
		verifyEq(ent3.email,	`minny.mouse@disney.com`)
		verifyEq(ent3.age, 		34)
		
		ds.delete(ent3)
		verifyEq(ds.size, 		1)
		
		ds.drop
	}
	
	Void testDatastoreCheckedMethodsReturnNull() {
		minny := ds.findOne(false) { it->_id = 69 }
		verifyNull(minny)

		minny = ds.get(69, false)
		verifyNull(minny)
	}
}

@Entity 
internal class T_Entity14 {
	@BsonProp Int _id 
	@BsonProp Str name 	
	@BsonProp Uri email
	@BsonProp Int age
	
	new make(|This|in) { in(this) }
}
