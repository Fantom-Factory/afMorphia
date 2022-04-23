using afBson::Binary
using afBson::ObjectId
using afBson::MinKey
using afBson::MaxKey
using afBson::Timestamp

internal class TestOrmLiteralConverters : Test {
	private ObjectId objId 	:= ObjectId()
	private DateTime now	:= DateTime.now

	Void testLiteralsToBson() {
		entity := T_Entity08() {
			
			// BSON literals
			float 		= 69.0f
			str 		= "string"
			doc			= Str:Str?["wot":"ever"]
			list		= Str["wot","ever"]
			binaryStd	= Binary("dragon".toBuf)
			binaryMd5	= Binary("dragon".toBuf, Binary.BIN_MD5)
			binaryOld	= Binary("dragon".toBuf, Binary.BIN_BINARY_OLD)
			binaryBuf	= "vampire".toBuf
			objectId	= objId
			bool		= true
			dateTime	= now
			nul			= null
			regex		= "2 problems".toRegex
			timestamp	= Timestamp(500, 69)
			int 		= 69
			minKey		= MinKey.defVal
			maxKey		= MaxKey.defVal
			
			// Fantom types
			date		= Date.today
			dateTime	= now
			depend		= Depend("afAwesome 2.0+")
			duration	= 3sec
			enumm		= T_Entity08_Enum.wot
			field		= TestOrmLiteralConverters#now
			locale		= Locale("en")
			method		= Test#setup
			mimeType	= MimeType("mime/type")
			range		= 2..<4
			regex		= "2 problems".toRegex
			slot		= Test#setup
			time		= Time(13, 14, 15)
			timeZone	= TimeZone.rel
			type		= Test[]?#
			unit		= Unit("°C")
			uri			= `http://wotever/`
			uuid		= Uuid("088e6a43-3cd0-b300-62f7-c85b768bcc22")
			version		= Version("1.2.3.4")
		}
		
		bsonObj := BsonConvs().toBsonVal(entity) as Str:Obj?
		
		verifyEq	(bsonObj["float"],		entity.float)
		verifySame	(bsonObj["str"],		entity.str)
		verifyEq	(bsonObj["doc"],		Str:Obj?["wot":"ever"])	// all mongo maps have the Str:Obj? signature
		verifySame	(bsonObj["list"],		entity.list)
		verifySame	(bsonObj["binaryStd"],	entity.binaryStd)
		verifySame	(bsonObj["binaryMd5"],	entity.binaryMd5)
		verifySame	(bsonObj["binaryOld"],	entity.binaryOld)
		verifySame	(bsonObj["binaryBuf"],	entity.binaryBuf)
		verifySame	(bsonObj["objectId"],	entity.objectId)
		verifyEq	(bsonObj["bool"],		entity.bool)
		verifySame	(bsonObj["dateTime"],	entity.dateTime)
		verifySame	(bsonObj["nul"],		entity.nul)
		verifySame	(bsonObj["regex"],		entity.regex)
		verifySame	(bsonObj["timestamp"],	entity.timestamp)
		verifyEq	(bsonObj["int"],		entity.int)
		verifySame	(bsonObj["minKey"],		entity.minKey)
		verifySame	(bsonObj["maxKey"],		entity.maxKey)

		verifyEq	(bsonObj["date"],		entity.date.midnight(TimeZone.utc))
		verifyEq	(bsonObj["depend"],		entity.depend.toStr)
		verifyEq	(bsonObj["duration"],	entity.duration.toStr)
		verifyEq	(bsonObj["enumm"],		entity.enumm.toStr)
		verifyEq	(bsonObj["field"],		entity.field.toStr)
		verifyEq	(bsonObj["locale"],		entity.locale.toStr)
		verifyEq	(bsonObj["method"],		entity.method.toStr)
		verifyEq	(bsonObj["mimeType"],	entity.mimeType.toStr)
		verifyEq	(bsonObj["range"],		entity.range.toStr)
		verifyEq	(bsonObj["slot"],		entity.slot.toStr)
		verifyEq	(bsonObj["time"],		entity.time.toStr)
		verifyEq	(bsonObj["timeZone"],	entity.timeZone.toStr)
		verifyEq	(bsonObj["type"],		entity.type.toStr)
		verifyEq	(bsonObj["unit"],		entity.unit.toStr)
		verifyEq	(bsonObj["uri"],		entity.uri.toStr)
		verifyEq	(bsonObj["uuid"],		entity.uuid.toStr)
		verifyEq	(bsonObj["version"],	entity.version.toStr)
	}
	
	Void testLiteralsFromBson() {
		bsonObj := [
			// BSON literals
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
			"timestamp"		: Timestamp(500, 69),
			"int"			: 666,
			"minKey"		: MinKey.defVal,
			"maxKey"		: MaxKey.defVal,

			// Fantom types
			"date"			: Date.today.midnight(TimeZone.utc),
			"depend"		: "afAwesome 2.0+",
			"duration"		: 3sec.toStr,
			"enumm"			: "wot",
			"field"			: TestOrmLiteralConverters#now.qname,
			"locale"		: "en",
			"method"		: Test#setup.qname,
			"mimeType"		: "mime/type",
			"range"			: "2..<4",
			"slot"			: Test#setup.qname,
			"time"			: Time(13, 14, 15).toStr,
			"timeZone"		: "Etc/Rel",
			"type"			: "sys::Test[]?",
			"unit"			: "°C",
			"uri"			: "http://wotever/",
			"uuid"			: "088e6a43-3cd0-b300-62f7-c85b768bcc22",
			"version"		: "1.2.3.4",
		]

		entity := (T_Entity08) BsonConvs().fromBsonVal(bsonObj, T_Entity08#)

		verifyEq	(entity.float,		bsonObj["float"])
		verifySame	(entity.str, 		bsonObj["str"])
		verifyEq	(entity.doc.size,	bsonObj["doc"]->size)	// the two maps have diff sigs Str:Obj? vs Str:Str?
		verifyEq	(entity.list.size,	bsonObj["list"]->size)	// again Obj? vs Str?
		verifySame	(entity.binaryStd,	bsonObj["binaryStd"])
		verifySame	(entity.binaryMd5,	bsonObj["binaryMd5"])
		verifySame	(entity.binaryOld,	bsonObj["binaryOld"])
		verifySame	(entity.binaryBuf,	bsonObj["binaryBuf"])
		verifySame	(entity.objectId, 	bsonObj["objectId"])
		verifyEq	(entity.bool, 		bsonObj["bool"])
		verifySame	(entity.dateTime,	bsonObj["dateTime"])
		verifySame	(entity.nul, 		bsonObj["nul"])
		verifySame	(entity.regex, 		bsonObj["regex"])
		verifySame	(entity.timestamp,	bsonObj["timestamp"])
		verifyEq	(entity.int,		bsonObj["int"])
		verifySame	(entity.minKey,		bsonObj["minKey"])
		verifySame	(entity.maxKey,		bsonObj["maxKey"])

		verifyEq	(entity.date,		Date.today)
		verifyEq	(entity.depend,		Depend("afAwesome 2.0+"))
		verifyEq	(entity.duration,	3sec)
		verifyEq	(entity.enumm,		T_Entity08_Enum.wot)
		verifyEq	(entity.field,		TestOrmLiteralConverters#now)
		verifyEq	(entity.locale,		Locale("en"))
		verifyEq	(entity.method,		Test#setup)
		verifyEq	(entity.mimeType,	MimeType("mime/type"))
		verifyEq	(entity.range,		2..<4)
		verifyEq	(entity.slot,		Test#setup)
		verifyEq	(entity.time,		Time(13, 14, 15))
		verifyEq	(entity.timeZone,	TimeZone.rel)
		verifyEq	(entity.type,		Test[]?#)
		verifyEq	(entity.unit,		Unit("°C"))
		verifyEq	(entity.uri,		`http://wotever/`)
		verifyEq	(entity.uuid,		Uuid("088e6a43-3cd0-b300-62f7-c85b768bcc22"))
		verifyEq	(entity.version,	Version("1.2.3.4"))
	}
}

internal class T_Entity08 {
	// BSON Literals
	@BsonProp	Float		float
	@BsonProp	Str			str
	@BsonProp	Str:Str?	doc
	@BsonProp	Str?[]		list
	@BsonProp	Binary		binaryStd
	@BsonProp	Binary		binaryMd5
	@BsonProp	Binary		binaryOld
	@BsonProp	Buf			binaryBuf
	@BsonProp	ObjectId	objectId
	@BsonProp	Bool?		bool
	@BsonProp	DateTime?	dateTime
	@BsonProp	Obj?		nul
	@BsonProp	Regex		regex
	@BsonProp	Timestamp	timestamp
	@BsonProp	Int?		int
	@BsonProp	MinKey		minKey
	@BsonProp	MaxKey		maxKey
	
	// Fantom types
	@BsonProp	Date		date
	@BsonProp	Depend?		depend
	@BsonProp	Duration	duration
	@BsonProp	T_Entity08_Enum	enumm
	@BsonProp	Field?		field
	@BsonProp	Locale?		locale
	@BsonProp	Method?		method
	@BsonProp	MimeType?	mimeType
	@BsonProp	Range		range
	@BsonProp	Slot		slot
	@BsonProp	Time		time
	@BsonProp	TimeZone?	timeZone
	@BsonProp	Type		type
	@BsonProp	Unit?		unit
	@BsonProp	Uri			uri
	@BsonProp	Uuid?		uuid
	@BsonProp	Version?	version
	
	new make(|This|in) { in(this) }
}

internal enum class T_Entity08_Enum {
	wot, ever;
}
