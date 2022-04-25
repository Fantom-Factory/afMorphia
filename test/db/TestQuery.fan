using afBson::ObjectId
using afMongo::MongoIdx
using afMongo::MongoQ

internal class TestQuery : MorphiaDbTest {
	
	Datastore?	ds
	
	override Void setup() {
		super.setup
		
		this.ds = morphia[T_Entity18#]
		
		ds.drop(false)
		ds.insert(T_Entity18("Judge",   16))
		ds.insert(T_Entity18("Dredd",   19))
		ds.insert(T_Entity18("Wotever", 20))
		
		ds.collection.index("_text_").ensure(["name":MongoIdx.TEXT])
	}

	// ---- Comparison Query Operators ------------------------------------------------------------

	Void testEq() {
		res := (T_Entity18[]) ds.findAll(null) {
			eq(T_Entity18#name, "Judge")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
	}

	Void testNotEq() {
		res := query {
			notEq(T_Entity18#name, "Judge")
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")
		verifyEq(res[1].name, "Wotever")
	}

	Void testIn() {
		res := query {
			in("name", "Judge Judy".split)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
	}
	
	Void testNotIn() {
		res := query {
			notIn("name", "Judge Wotever".split)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}
	
	Void testGreaterThan() {		
		res := query {
			greaterThan("value", 19)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.value, 20)
	}
	
	Void testGreaterThanOrEqualTo() {		
		res := query {
			greaterThanOrEqTo("value", 19)
		}
		verifyEq(res.size, 2)
		verifyEq(res.first.value, 19)
		verifyEq(res[1].value, 20)
	}
	
	Void testLessThan() {		
		res := query {
			lessThan("value", 19)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.value, 16)
	}
	
	Void testLessThanOrEqualTo() {		
		res := query {
			lessThanOrEqTo("value", 19)
		}
		verifyEq(res.size, 2)
		verifyEq(res.first.value, 16)
		verifyEq(res[1].value, 19)
	}
	
	// ---- Element Query Operators ---------------------------------------------------------------

	Void testExists() {		
		res := query {
			exists("value")
		}
		verifyEq(res.size, 3)
		res = query {
			exists("value", false)
		}
		verifyEq(res.size, 0)
	}

	// ---- String Query Operators ----------------------------------------------------------------

	Void testEqIgnoreCase() {
		res := query {
			eqIgnoreCase("name", "judge")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
	}
	
	Void testContains() {
		res := query {
			contains("name", "ud")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")

		res = query {
			contains("name", "RE", true)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}
	
	Void testStartsWith() {
		ds.insert(T_Entity18("Dreddnought", -1))
		res := query {
			startsWith("name", "Dredd")
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")
		verifyEq(res[1].name, "Dreddnought")

		res = query {
			startsWith("name", "DREDD", true)
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")
		verifyEq(res[1].name, "Dreddnought")
	}

	Void testEndsWith() {
		ds.insert(T_Entity18("Neverever", -1))
		res := query {
			endsWith("name", "ever")
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Wotever")
		verifyEq(res[1].name, "Neverever")

		res = query {
			endsWith("name", "EVER", true)
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Wotever")
		verifyEq(res[1].name, "Neverever")
	}
	
	// ---- Logical Query Operators --------------------------------------------------------------
	
	Void testAnd() {
		res := query {
			and(
				eq("name", "Dredd"),
				eq("value", 19)
			)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}

	Void testOr() {
		res := query {
			or(
				eq("name", "Judge"),
				eq("name", "Dredd")
			)
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Judge")
		verifyEq(res[1].name, "Dredd")
	}

	Void testNot() {
		res := query {
			in("name", "Dredd".split).not
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Judge")
		verifyEq(res[1].name, "Wotever")
		
		res = query {
			not(in("name", "Dredd".split))
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Judge")
		verifyEq(res[1].name, "Wotever")		

		res = query {
			not.in("name", "Dredd".split)
		}
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Judge")
		verifyEq(res[1].name, "Wotever")
	}

	Void testNor() {
		res := query {
			nor(
				eq("name", "Judge"),
				eq("name", "Dredd")
			)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Wotever")
	}

	// ---- Evaluation Query Operators ------------------------------------------------------------

	Void testMod() {
		res := query {
			mod("value", 8, 0)
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
		verifyEq(res.first.value, 16)
	}

	Void testWhere() {
		res := query {
			where("this.name == 'Dredd'")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}

	Void testTextSearch() {
		res := query {
			textSearch("Dredd")
		}
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}
	
	// ---- Sort Tests ----------------------------------------------------------------------------
	
	Void testSort() {
		ds.insert(T_Entity18("Dredd", 22))
		res := (T_Entity18[]) ds.find(null) {
			it->sort = Str:Obj[:]{ordered=true}.add("name", 1).add("value", -1)
		}.toList
		verifyEq(res.size, 4)
		verifyEq(res[0].name,  "Dredd")
		verifyEq(res[0].value, 22)
		verifyEq(res[1].name, "Dredd")
		verifyEq(res[1].value, 19)
		verifyEq(res[2].name, "Judge")
		verifyEq(res[3].name, "Wotever")
	}
	
	// ---- Misc Methods --------------------------------------------------------------------------
	
	Void testListType() {
		res := ds.findAll
		verifyFalse(res.isEmpty)
		verifyEq(res.typeof.params["V"], T_Entity18#)
	}

	Void testEmptyListType() {
		ds.drop
		res := ds.findAll
		verify(res.isEmpty)
		verifyEq(res.typeof.params["V"], T_Entity18#)
	}
	
	private T_Entity18[] query(|MongoQ| fn) {
		ds.findAll(null, fn)
	}
}

@Entity
internal class T_Entity18 {
	
	@BsonProp	ObjectId	_id	:= ObjectId() 
	@BsonProp	Str?		name
	@BsonProp	Str?		summary
	@BsonProp	Int?		value

	new make(|This| in) { in(this) }

	new makeText(Str name, Str summary) {
		this.name 	 = name
		this.summary = summary
	}

	new makeName(Str name, Int value) {
		this.name  = name
		this.value = value
	}
}
