using afIoc
using afBson

// Texy search
// http://docs.mongodb.org/manual/reference/operator/query/text/#op._S_text
internal class TestQuery : MorphiaDbTest {
	
	@Inject { type=T_Entity18# } 
	Datastore?	ds
	
	override Void setup() {
		super.setup
		ds.drop(false)
		ds.insert(T_Entity18("Judge",   16))
		ds.insert(T_Entity18("Dredd",   19))
		ds.insert(T_Entity18("Wotever", 20))
	}

	// ---- Comparison Query Operators ------------------------------------------------------------

	Void testEq() {
		res := query(field("name").eq("Judge"))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
	}

	Void testNotEq() {
		res := query(field("name").notEq("Judge"))
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")
		verifyEq(res[1].name, "Wotever")
	}

	Void testIn() {
		res := query(field("name").in("Judge Judy".split))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
	}
	
	Void testNotIn() {
		res := query(field("name").notIn("Judge Wotever".split))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}
	
	Void testGreaterThan() {		
		res := query(field("value").greaterThan(19))
		verifyEq(res.size, 1)
		verifyEq(res.first.value, 20)
	}
	
	Void testGreaterThanOrEqualTo() {		
		res := query(field("value").greaterThanOrEqTo(19))
		verifyEq(res.size, 2)
		verifyEq(res.first.value, 19)
		verifyEq(res[1].value, 20)
	}
	
	Void testLessThan() {		
		res := query(field("value").lessThan(19))
		verifyEq(res.size, 1)
		verifyEq(res.first.value, 16)
	}
	
	Void testLessThanOrEqualTo() {		
		res := query(field("value").lessThanOrEqTo(19))
		verifyEq(res.size, 2)
		verifyEq(res.first.value, 16)
		verifyEq(res[1].value, 19)
	}
	
	// ---- Element Query Operators ---------------------------------------------------------------

	Void testExists() {		
		res := query(field("value").exists(true))
		verifyEq(res.size, 3)
		res = query(field("value").exists(false))
		verifyEq(res.size, 0)
	}

	// ---- String Query Operators ----------------------------------------------------------------

	Void testEqIgnoreCase() {
		res := query(field("name").eqIgnoreCase("judge"))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
	}
	
	Void testContains() {
		res := query(field("name").contains("ud", false))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")

		res = query(field("name").contains("RE", true))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}
	
	Void testStartsWith() {
		ds.insert(T_Entity18("Dreddnought", -1))
		res := query(field("name").startsWith("Dredd", false))
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")
		verifyEq(res[1].name, "Dreddnought")

		res = query(field("name").startsWith("DREDD", true))
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Dredd")
		verifyEq(res[1].name, "Dreddnought")
	}

	Void testEndsWith() {
		ds.insert(T_Entity18("Neverever", -1))
		res := query(field("name").endsWith("ever", false))
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Wotever")
		verifyEq(res[1].name, "Neverever")

		res = query(field("name").endsWith("EVER", true))
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Wotever")
		verifyEq(res[1].name, "Neverever")
	}
	
	// ---- Logical Query Operators --------------------------------------------------------------
	
	Void testImplicitAnd() {
		res := query(field("name").eq("Dredd").field("value").eq(19))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}

	Void testImplicitAndSameField() {
		res := query(field("value").greaterThan(16).field("value").lessThan(20))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
	}

	Void testAnd() {
		res := query(Query().and([
			field("name").eq("Dredd"),
			field("value").eq(19)
		]))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
		
		verifyErrMsg(ArgErr#, "Key already mapped: \$and") {
			Query()
				.and([field("name").eq("Judge")])
				.and([field("name").eq("Judge")])
				.toMongo(ds)
		}
	}

	Void testOr() {
		res := query(Query().or([
			field("name").eq("Judge"),
			field("name").eq("Dredd")
		]))
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Judge")
		verifyEq(res[1].name, "Dredd")

		verifyErrMsg(ArgErr#, "Key already mapped: \$or") {
			Query()
				.or([field("name").eq("Judge")])
				.or([field("name").eq("Judge")])
				.toMongo(ds)
		}
	}

	Void testNot() {
		res := query(field("name").not.in(["Dredd"]))
		verifyEq(res.size, 2)
		verifyEq(res[0].name, "Judge")
		verifyEq(res[1].name, "Wotever")
	}

	Void testNor() {
		res := query(Query().nor([
			field("name").eq("Judge"),
			field("name").eq("Dredd")
		]))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Wotever")

		verifyErrMsg(ArgErr#, "Key already mapped: \$nor") {
			Query()
				.nor([field("name").eq("Judge")])
				.nor([field("name").eq("Judge")])
				.toMongo(ds)
		}
	}

	// ---- Evaluation Query Operators ------------------------------------------------------------

	Void testMod() {
		res := query(field("value").mod(8, 0))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Judge")
		verifyEq(res.first.value, 16)
	}

	Void testWhere() {
		res := query(Query().where(Code("this.name == 'Dredd'")))
		verifyEq(res.size, 1)
		verifyEq(res.first.name, "Dredd")
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
internal class T_Entity18 {
	
	@Property	ObjectId	_id	:= ObjectId() 
	@Property	Str?		name
	@Property	Int?		value

	@Inject
	new make(|This| in) { in(this) }

	new makeName(Str name, Int value) {
		this.name = name
		this.value = value
	}
}