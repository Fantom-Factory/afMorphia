using afIoc::Inject
using afMongo::Index
using afBson::ObjectId

internal class TestQueryTextSearch : MorphiaDbTest {
	
	@Inject { type=T_Entity18# } 
	Datastore?	ds
	
	@Inject { type=T_Entity27# } 
	Datastore?	ds2
	
	override Void setup() {
		super.setup
		ds.drop
		ds.insert(T_Entity18("Dredd",		"Judges Dredd Anderson"))
		ds.insert(T_Entity18("Anderson",	"Judges Dredd Dredd Anderson"))
		ds.insert(T_Entity18("Wotever",		"Judges"))
		
		indexKey := Str:Obj[:] { it.ordered=true } .add("name", Index.TEXT).add("summary", Index.TEXT)
		ds.collection.index("_text_").ensure(indexKey, false, ["weights":["name":2, "summary":1]])
	}
	
	// ---- Evaluation Query Operators ------------------------------------------------------------
	
	Void testTextSearchBasic() {
		res := query(Query().textSearch("Wotever"))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Wotever")

		res = query(Query().textSearch("no match"))
		verifyEq(res.size, 0)
	}
	
	Void testTextSearchWeights() {
		res := query(Query().textSearch("Dredd"))		
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")		// Dredd comes first 'cos name is more heavily weighted
		verifyEq(res[1].name, "Anderson")

		res = query(Query().textSearch("Anderson"))		
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Anderson")	// now Anderson comes first 'cos name is more heavily weighted
		verifyEq(res[1].name, "Dredd")
	}
	
	Void testTextSearchCaseSensitive() {
		res := query(Query().textSearch("Wotever", ["\$caseSensitive":true]))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Wotever")

		res = query(Query().textSearch("wotever", ["\$caseSensitive":true]))
		verifyEq(res.size, 0)
	}

	Void testTextSearchPhrase() {
		res := query(Query().textSearch("Dredd Dredd"))
		verifyEq(res.size, 2)

		res = query(Query().textSearch("\"Dredd Dredd\""))
		verifyEq(res.size, 1)
		verifyEq(res[0].name, "Anderson")

		res = query(Query().textSearch("\"no match\""))
		verifyEq(res.size, 0)
	}

	Void testTextSearchNegation() {
		res := query(Query().textSearch("Judges"))
		verifyEq(res.size, 3)

		res = query(Query().textSearch("Judges -Dredd"))
		verifyEq(res.size, 1)
		verifyEq(res[0].name, "Wotever")
	}

	Void testMapSearch() {
		ds2.drop
		ds2.collection.create

		// this test is essentially exploring this:
		// https://stackoverflow.com/questions/51545914/text-search-on-any-document-value-in-mongodb
		
		indexKey := Str:Obj[:] { it.ordered=true } .add("name", Index.TEXT).add("\$**", Index.TEXT)
		ds2.collection.index("_text_").ensure(indexKey, false)

		ent := ds2.insert(T_Entity27("Dredd") {
			it.docs = ["readme" : "Please do!", "axonFuncs" : "if this then do that"] 
		}) as T_Entity27
		
		doc := ds2.toMongoDoc(ent)
		doc.remove("docs")
		doc["name"] = "Dredd"
		
		ds2.collection.update(["_id":ent._id], ["\$set":doc])
		ent2 := ds2.get(doc["_id"]) as T_Entity27

		// verify the save
		verifyEq(ent2.name, "Dredd")
		
		// verify "docs2 hasn't been deleted 
		verifyEq(ent2.docs["readme"], "Please do!")
		
		q	:= Query().textSearch("Dude")
		res := ds2.query(q).findAll
		verifyEq(res.size, 0)
		
		q	= Query().textSearch("Dredd")
		res = ds2.query(q).findAll
		verifyEq(res.size, 1)
		verifyEq(res.first->name, "Dredd")

		q	= Query().textSearch("Please")
		res = ds2.query(q).findAll
		verifyEq(res.size, 1)
		verifyEq(res.first->name, "Dredd")
	}

	// ---- Private Methods -----------------------------------------------------------------------
	
	// squirrel this away
	QueryCriterion field(Str fieldName) {
		Query().field(fieldName)
	}
	
	T_Entity18[] query(Query q) {
		ds.query(q).findAll
	}
}

@Entity
internal class T_Entity27 {

	@Property	ObjectId	_id	:= ObjectId() 
	@Property	Str			name
	@Property	[Str:Str]?	docs

	@Inject
	new make(|This| in) { in(this) }

	new makeName(Str name) {
		this.name = name
	}
}