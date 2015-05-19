using afIoc
using afBson

internal class TestLiteralConversion : MorphiaTest {
	private ObjectId objId 	:= ObjectId()
	private DateTime now	:= DateTime.now

	@Inject Converters? serialiser
	
	Void testLiteralsToFantom() {
		mongoDoc := [
			"_id"			: -1,
			
			// Mongo literals
			"float"			: 69f,
			"str"			: "string",
			"doc"			: Str:Obj?["wot":"ever"],
			"list"			: Obj?["wot","ever"],
			"binaryStd"		: Binary("dragon".toBuf),
			"binaryMd5"		: Binary("dragon".toBuf, Binary.BIN_MD5),
			"binaryOld"		: Binary("dragon".toBuf, Binary.BIN_BINARY_OLD),
			"binaryBuf"		: "vampire".toBuf,
			"objectId"		: objId,
			"bool"			: true,
			"dateTime"		: now,
			"nul"			: null,
			"regex"			: "2 problems".toRegex,
			"code"			: Code("func() { ... }"),
			"codeScope"		: Code("func() { ... }", ["wot":"ever"]),
			"timestamp"		: Timestamp(3sec, 69),
			"int"			: 666,
			"minKey"		: MinKey(),
			"maxKey"		: MaxKey(),
			
			// Fantom literals
			"date"			: Date.today.toDateTime(Time.defVal),
			"enumm"			: "wot",
			"uri"			: "http://uri",
			"decimal"		: "6.9",
			"duration"		: "3sec",
			"type"			: "afMorphia::MorphiaTest",
			"slot"			: "afMorphia::MorphiaTest.setup",
			"range"			: "2..<4",
			"map"			: Str:Obj?["3":"ever"],
		]
		
		entity := (T_Entity01) serialiser.toFantom(T_Entity01#, mongoDoc)
		
		// Mongo literals
		verifyEq  (entity.float,		mongoDoc["float"])
		verifySame(entity.str, 			mongoDoc["str"])
		verifyEq  (entity.doc.size,		mongoDoc["doc"]->size)	// the two maps have diff sigs Str:Obj? vs Str:Str?
		verifyEq  (entity.list.size,	mongoDoc["list"]->size)	// again Obj? vs Str?
		verifySame(entity.binaryStd,	mongoDoc["binaryStd"])
		verifySame(entity.binaryMd5,	mongoDoc["binaryMd5"])
		verifySame(entity.binaryOld,	mongoDoc["binaryOld"])
		verifySame(entity.binaryBuf,	mongoDoc["binaryBuf"])
		verifySame(entity.objectId, 	mongoDoc["objectId"])
		verifyEq  (entity.bool, 		mongoDoc["bool"])
		verifySame(entity.dateTime,		mongoDoc["dateTime"])
		verifySame(entity.nul, 			mongoDoc["nul"])
		verifySame(entity.regex, 		mongoDoc["regex"])
		verifySame(entity.code,			mongoDoc["code"])
		verifySame(entity.codeScope,	mongoDoc["codeScope"])
		verifySame(entity.timestamp,	mongoDoc["timestamp"])
		verifyEq  (entity.int,			mongoDoc["int"])
		verifySame(entity.minKey,		mongoDoc["minKey"])
		verifySame(entity.maxKey,		mongoDoc["maxKey"])
		
		m:=(Int:T_Entity01_Enum?[:]{ordered=true}).add(3,T_Entity01_Enum.ever)
		// Fantom literals
		verifyEq(entity.date, 			Date.today)
		verifyEq(entity.enumm,			T_Entity01_Enum.wot)
		verifyEq(entity.uri,			`http://uri/`)
		verifyEq(entity.decimal,		6.9d)
		verifyEq(entity.duration,		3sec)
		verifyEq(entity.type,			MorphiaTest#)
		verifyEq(entity.slot,			MorphiaTest#setup)
		verifyEq(entity.range,			2..<4)
		verifyEq(entity.map, 			m)
	}
	
	Void testLiteralsToMongo() {
		entity := T_Entity01() {
			
			// Mongo literals			
			float 		= 69.0f
			str 		= "string"
			doc			= Str:Str?["wot":"ever"]
			list		= ["wot","ever"]
			binaryStd	= Binary("dragon".toBuf)
			binaryMd5	= Binary("dragon".toBuf, Binary.BIN_MD5)
			binaryOld	= Binary("dragon".toBuf, Binary.BIN_BINARY_OLD)
			binaryBuf	= "vampire".toBuf
			objectId	= objId
			bool		= true
			dateTime	= now
			nul			= null
			regex		= "2 problems".toRegex
			code		= Code("func() { ... }")
			codeScope	= Code("func() { ... }", ["wot":"ever"])
			timestamp	= Timestamp(3sec, 69)
			int 		= 69
			minKey		= MinKey()
			maxKey		= MaxKey()
			
			// Fantom literals
			date		= Date.today
			enumm		= T_Entity01_Enum.wot
			uri			= `http://uri`
			decimal		= 6.9d
			duration	= 3sec
			type		= MorphiaTest#
			slot		= MorphiaTest#setup
			range		= (2..<4)
			map			= [3:T_Entity01_Enum.ever]
		}
		
		mongoDoc := serialiser.toMongo(entity) as Map
		
		verifyEq  (mongoDoc["float"],		entity.float)
		verifySame(mongoDoc["str"],			entity.str)
		verifyEq  (mongoDoc["doc"],			Str:Obj?["wot":"ever"])	// all mongo maps have the Str:Obj? signature
		verifySame(mongoDoc["list"],		entity.list)
		verifySame(mongoDoc["binaryStd"],	entity.binaryStd)
		verifySame(mongoDoc["binaryMd5"],	entity.binaryMd5)
		verifySame(mongoDoc["binaryOld"],	entity.binaryOld)
		verifySame(mongoDoc["binaryBuf"],	entity.binaryBuf)
		verifySame(mongoDoc["objectId"],	entity.objectId)
		verifyEq  (mongoDoc["bool"],		entity.bool)
		verifySame(mongoDoc["dateTime"],	entity.dateTime)
		verifySame(mongoDoc["nul"],			entity.nul)
		verifySame(mongoDoc["regex"],		entity.regex)
		verifySame(mongoDoc["code"],		entity.code)
		verifySame(mongoDoc["codeScope"],	entity.codeScope)
		verifySame(mongoDoc["timestamp"],	entity.timestamp)
		verifyEq  (mongoDoc["int"],			entity.int)
		verifySame(mongoDoc["minKey"],		entity.minKey)
		verifySame(mongoDoc["maxKey"],		entity.maxKey)
		
		verifyEq(mongoDoc["date"],			Date.today.toDateTime(Time.defVal))
		verifyEq(mongoDoc["enumm"],			"wot")
		verifyEq(mongoDoc["uri"],			"http://uri/")
		verifyEq(mongoDoc["decimal"],		"6.9")
		verifyEq(mongoDoc["duration"],		"3sec")
		verifyEq(mongoDoc["type"],			"afMorphia::MorphiaTest")
		verifyEq(mongoDoc["slot"],			"afMorphia::MorphiaTest.setup")
		verifyEq(mongoDoc["range"],			"2..<4")
		verifyEq(mongoDoc["map"],			Str:Obj?["3":"ever"])
	}
}

@Entity
internal class T_Entity01 {
	@Property	Int			_id
	
	// Mongo Literals
	@Property	Float		float
	@Property	Str			str
	@Property	Str:Str?	doc
	@Property	Str?[]		list
	@Property	Binary		binaryStd
	@Property	Binary		binaryMd5
	@Property	Binary		binaryOld
	@Property	Buf			binaryBuf
	@Property	ObjectId	objectId
	@Property	Bool?		bool
	@Property	DateTime?	dateTime
	@Property	Obj?		nul
	@Property	Regex		regex
	@Property	Code		code
	@Property	Code		codeScope
	@Property	Timestamp	timestamp
	@Property	Int?		int
	@Property	MinKey		minKey
	@Property	MaxKey		maxKey
	
	// Fantom literals
	@Property	Date		date
	@Property	T_Entity01_Enum	enumm
	@Property	Uri			uri
	@Property	Decimal		decimal
	@Property	Duration	duration
	@Property	Type		type
	@Property	Slot		slot
	@Property	Range		range
	@Property	Int:T_Entity01_Enum?	map
	
	// Moar Fantom Classes
	@Property	Field?		field
	@Property	Depend?		depend
	@Property	Locale?		locale
	@Property	Method?		method
	@Property	MimeType?	mimeType
	@Property	Time?		time
	@Property	TimeZone?	timeZone
	@Property	Unit?		unit
	@Property	Uuid?		uuid
	@Property	Version?	version
	
	new make(|This|in) { in(this) }
}

internal enum class T_Entity01_Enum {
	wot, ever;
}