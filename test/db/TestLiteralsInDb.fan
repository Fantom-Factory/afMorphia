using afBson::Binary
using afBson::ObjectId
using afBson::Timestamp
using afBson::MaxKey
using afBson::MinKey

internal class TestLiteralsInDb : MorphiaDbTest {
	
	Datastore?	ds
	
	private ObjectId objId 	:= ObjectId()
	private DateTime now	:= DateTime.now
	
	override Void setup() {
		super.setup
		this.ds = morphia[T_Entity08#]
	}
	
	Void testStoringLiterals() {
		entity := T_Entity08 {
			
			// Mongo literals			
			float 		= 69.0f
			str 		= "string"
			doc			= ["wot":"ever"]
			list		= ["wot","ever"]
			binaryMd5	= Binary("dragon".toBuf, Binary.BIN_MD5)
			binaryOld	= Binary("dragon".toBuf, Binary.BIN_BINARY_OLD)
			binaryBuf	= "vampire".toBuf
			objectId	= objId
			bool		= true
			dateTime	= now
			nul			= null
			regex		= "2 problems".toRegex
			timestamp	= Timestamp(500, 69)
			int 		= 999
			minKey		= MinKey.defVal
			maxKey		= MaxKey.defVal
			
			// Fantom literals
			date		= Date.today
			enumm		= T_Entity08_Enum.wot
			uri			= `http://uri`
			duration	= 3sec
			type		= TestLiteralsInDb#
			slot		= TestLiteralsInDb#setup
			range		= (2..<4)
			map			= [3:T_Entity08_Enum.ever]
			
			// Moar Fantom classes
			field		= TestLiteralsInDb#now
			depend		= Depend("afIoc 2.0.6 - 2.0")
			locale		= Locale("en-GB")
			method		= TestLiteralsInDb#setup
			mimeType	= MimeType("text/plain")
			time		= Time(2, 22, 22, 22)
			timeZone	= TimeZone.utc
			unit		= Unit("pH")
			uuid		= Uuid("03f0e2bb-8f1a-c800-e1f8-00623f7473c4")
			version		= Version([6, 9, 6, 9])
		}
		
		ds.insert(entity)
		entity = ds.findAll.first
		
		// Mongo types
		verifyEq(entity.float, 		69f)
		verifyEq(entity.str, 		"string")
		verifyEq(entity.doc["wot"],	"ever")
		verifyEq(entity.list[0], 	"wot")
		verifyEq(entity.list[1], 	"ever")
		verifyEq(entity.binaryMd5.subtype,				Binary.BIN_MD5)
		verifyEq(entity.binaryMd5.data.in.readAllStr,	"dragon")
		verifyEq(entity.binaryOld.subtype,				Binary.BIN_BINARY_OLD)
		verifyEq(entity.binaryOld.data.in.readAllStr,	"dragon")
		verifyEq(entity.binaryBuf.readAllStr,			"vampire")
		verifyEq(entity.objectId, 	objId)
		verifyEq(entity.bool, 		true)
		verifyEq(entity.dateTime,	now)
		verifyEq(entity.nul, 		null)
		verifyEq(entity.regex, 		"2 problems".toRegex)
		verifyEq(entity.timestamp,	Timestamp(500, 69))
		verifyEq(entity.int,		999)
		verifyEq(entity.minKey,		MinKey.defVal)
		verifyEq(entity.maxKey,		MaxKey.defVal)
		
		// Fantom types
		verifyEq(entity.date, 		Date.today)	
		verifyEq(entity.enumm,		T_Entity08_Enum.wot)
		verifyEq(entity.uri,		`http://uri/`)
		verifyEq(entity.duration,	3sec)
		verifyEq(entity.type,		TestLiteralsInDb#)
		verifyEq(entity.slot,		TestLiteralsInDb#setup)
		verifyEq(entity.range,		2..<4)
		verifyEq(entity.map[3],		T_Entity08_Enum.ever)

		// Moar Fantom classes
		verifyEq(entity.field,		TestLiteralsInDb#now)
		verifyEq(entity.depend,		Depend("afIoc 2.0.6 - 2.0"))
		verifyEq(entity.locale,		Locale("en-GB"))
		verifyEq(entity.method,		TestLiteralsInDb#setup)
		verifyEq(entity.mimeType,	MimeType("text/plain"))
		verifyEq(entity.time,		Time(2, 22, 22, 22))
		verifyEq(entity.timeZone,	TimeZone.utc)
		verifyEq(entity.unit,		Unit("pH"))
		verifyEq(entity.uuid,		Uuid("03f0e2bb-8f1a-c800-e1f8-00623f7473c4"))
		verifyEq(entity.version,	Version([6, 9, 6, 9]))
	}
}
