using afIoc::Inject
using afMongo::Index

internal class TestQueryTextSearch : MorphiaDbTest {
	
	@Inject { type=T_Entity18# } 
	Datastore?	ds
	
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

	// ---- Private Methods -----------------------------------------------------------------------
	
	// squirrel this away
	QueryCriterion field(Str fieldName) {
		Query().field(fieldName)
	}
	
	T_Entity18[] query(Query q) {
		ds.query(q).findAll
	}
}
