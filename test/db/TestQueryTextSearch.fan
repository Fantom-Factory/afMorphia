using afMongo::MongoIdx
using afMongo::MongoQ
using afBson::ObjectId

internal class TestQueryTextSearch : MorphiaDbTest {
	
	Datastore?	ds
	Datastore?	ds2
	
	override Void setup() {
		super.setup
		
		this.ds  = morphia[T_Entity18#]
		this.ds2 = morphia[T_Entity27#]
		
		ds.drop
		ds.insert(T_Entity18("Dredd",		"Judges Dredd Anderson"))
		ds.insert(T_Entity18("Anderson",	"Judges Dredd Dredd Anderson"))
		ds.insert(T_Entity18("Wotever",		"Judges"))
		
		indexKey := Str:Obj[:] { it.ordered=true } .add("name", MongoIdx.TEXT).add("summary", MongoIdx.TEXT)
		ds.collection.index("_text_").ensure(indexKey, false) {
			it->weights = ["name":2, "summary":1]
		}
	}
	
	// ---- Evaluation Query Operators ------------------------------------------------------------
	
	Void testTextSearchBasic() {
		res := query {
			textSearch("Wotever")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Wotever")

		res = query {
			textSearch("no match")
		}
		verifyEq(res.size, 0)
	}
	
	Void testTextSearchWeights() {
		res := query {
			textSearch("Dredd")
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")		// Dredd comes first 'cos name is more heavily weighted
		verifyEq(res[1].name, "Anderson")

		res = query {
			textSearch("Anderson")
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Anderson")	// now Anderson comes first 'cos name is more heavily weighted
		verifyEq(res[1].name, "Dredd")
	}
	
	Void testTextSearchCaseSensitive() {
		res := query {
			textSearch("Wotever", ["\$caseSensitive":true])
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Wotever")

		res = query {
			textSearch("wotever", ["\$caseSensitive":true])
		}
		verifyEq(res.size, 0)
	}

	Void testTextSearchPhrase() {
		res := query {
			textSearch("Dredd Dredd")
		}
		verifyEq(res.size, 2)

		res = query {
			textSearch("\"Dredd Dredd\"")
		}
		verifyEq(res.size, 1)
		verifyEq(res[0].name, "Anderson")

		res = query {
			textSearch("\"no match\"")
		}
		verifyEq(res.size, 0)
	}

	Void testTextSearchNegation() {
		res := query {
			textSearch("Judges")
		}
		verifyEq(res.size, 3)

		res = query {
			textSearch("Judges -Dredd")
		}
		verifyEq(res.size, 1)
		verifyEq(res[0].name, "Wotever")
	}

	Void testMapSearch() {
		ds2.drop
		ds2.collection.create

		// this test is essentially exploring this:
		// https://stackoverflow.com/questions/51545914/text-search-on-any-document-value-in-mongodb
		
		indexKey := Str:Obj[:] { it.ordered=true } .add("name", MongoIdx.TEXT).add("\$**", MongoIdx.TEXT)
		ds2.collection.index("_text_").ensure(indexKey, false)

		ent := ds2.insert(T_Entity27("Dredd") {
			it.docs = ["readme" : "Please do!", "axonFuncs" : "if this then do that"] 
		}) as T_Entity27
		
		doc := ds2.toBsonDoc(ent)
		doc.remove("docs")
		doc["name"] = "Dredd"
		
		ds2.collection.update(["_id":ent._id], ["\$set":doc])
		ent2 := ds2.get(doc["_id"]) as T_Entity27

		// verify the save
		verifyEq(ent2.name, "Dredd")
		
		// verify "docs2 hasn't been deleted 
		verifyEq(ent2.docs["readme"], "Please do!")
		
		res := ds2.findAll(null) {
			textSearch("Dude")
		}
		verifyEq(res.size, 0)
		
		res = ds2.findAll(null) {
			textSearch("Dredd")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first->name, "Dredd")

		res = ds2.findAll(null) {
			textSearch("Please")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first->name, "Dredd")
	}

	// ---- Private Methods -----------------------------------------------------------------------
	
	
	private T_Entity18[] query(|MongoQ| fn) {
		ds.findAll(null, fn)
	}
}

@Entity
internal class T_Entity27 {

	@BsonProp	ObjectId	_id	:= ObjectId() 
	@BsonProp	Str			name
	@BsonProp	[Str:Str]?	docs

	new make(|This| in) { in(this) }

	new makeName(Str name) {
		this.name = name
	}
}