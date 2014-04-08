using afIoc
using afMongo

internal class TestSerializeLiterals : MorphiaTest {

	@Inject Serializer? serializer
	
	Void testDeserializeMongoLiterals() {
		mongoDoc := [
			"float" 	: 69.0f,
			"int" 		: 69,
			"str" 		: "dude",
			"buf"		: Buf().writeChars("vampire"),
			"objectId"	: ObjectId(DateTime.fromJava(1), 2, 3, 4),
			"bool"		: true,
			"date"		: Date.today,
			"dateTime"	: DateTime.now,
			"nul"		: null,
			"regex"		: Regex.fromStr("2 problems"),
			"enumm"		: "wot"
		]
		
		entity := (T_Entity01) serializer.fromMongoDoc(mongoDoc, T_Entity01#)
		
		verifyEq(entity.float, 		mongoDoc["float"])	
		verifyEq(entity.int, 		mongoDoc["int"])	
		verifyEq(entity.str, 		mongoDoc["str"])	
		verifyEq(entity.buf, 		mongoDoc["buf"])	
		verifyEq(entity.objectId,	mongoDoc["objectId"])
		verifyEq(entity.bool, 		mongoDoc["bool"])	
		verifyEq(entity.date, 		mongoDoc["date"])	
		verifyEq(entity.dateTime,	mongoDoc["dateTime"])	
		verifyEq(entity.nul, 		mongoDoc["nul"])	
		verifyEq(entity.regex, 		mongoDoc["regex"])	
		verifyEq(entity.enumm,		T_Entity01_Enum.wot)
	}
	
	Void testSerializeMongoLiterals() {
		entity := T_Entity01() {
			float 		= 69.0f
			int 		= 69
			str 		= "dude"
			buf			= Buf().writeChars("vampire")
			objectId	= ObjectId(DateTime.fromJava(1), 2, 3, 4)
			bool		= true
			date		= Date.today
			dateTime	= DateTime.now
			nul			= null
			regex		= Regex.fromStr("2 problems")
			enumm		= T_Entity01_Enum.wot
		}
		
		mongoDoc := serializer.toMongoDoc(entity)
		
		verifyEq(mongoDoc["float"],		entity.float)
		verifyEq(mongoDoc["int"],		entity.int)
		verifyEq(mongoDoc["str"],		entity.str)
		verifyEq(mongoDoc["buf"],		entity.buf)
		verifyEq(mongoDoc["objectId"],	entity.objectId)
		verifyEq(mongoDoc["bool"],		entity.bool)
		verifyEq(mongoDoc["date"],		entity.date)
		verifyEq(mongoDoc["dateTime"],	entity.dateTime)
		verifyEq(mongoDoc["nul"],		entity.nul)
		verifyEq(mongoDoc["regex"],		entity.regex)
		verifyEq(mongoDoc["enumm"],		"wot")
	}
	
}

** Mongo Literals
internal class T_Entity01 {
	// Mongo Literals
	@Property	Float		float
	@Property	Int?		int
	@Property	Str			str
	@Property	Buf?		buf
	@Property	ObjectId	objectId
	@Property	Bool?		bool
	@Property	Date		date
	@Property	DateTime?	dateTime
	@Property	Obj?		nul
	@Property	Regex		regex
	
	// TODO: Fantom literals
	@Property	T_Entity01_Enum	enumm
	
//    sys::Decimal
//    sys::Duration
//    sys::Uri
//    sys::Type
//    sys::Slot
//    sys::Range
		
	new make(|This|in) { in(this) }
	
	// wierd Mongo literals
//	Symbol -> same as string?
//	Object (Fantom Map)
//	Array (Fantom List)
//	Timestamp -> same as Date?
//	Undefined -> same as Null?
//	Code w scope
//	MinKey
//	MaxKey
//	number int -> same as Int?
}

internal enum class T_Entity01_Enum {
	wot, ever;
}