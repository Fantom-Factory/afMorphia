using concurrent
using afIoc
using afBson
using afMongo

internal class TestLiteralsInDb : MorphiaTest {
	
	private ObjectId objId 	:= ObjectId()
	private DateTime now	:= DateTime.now

	@Inject Converters? serialiser
	
	MongoClient? mc
	Database?	 db
	
	override Void setup() {
		super.setup
		mc = MongoClient(ActorPool())
		db = mc["afMorphiaTest"].drop
	}

	override Void teardown() {
		mc?.shutdown
		super.teardown
	}
	
	Void testStoringLiterals() {
		entity := T_Entity01() {
			
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
			code		= Code("func() { ... }")
			codeScope	= Code("func() { ... }", Str:Obj?["wot":"ever"])
			timestamp	= Timestamp(3sec, 69)
			int 		= 999
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
		
		ds := reg.autobuild(Datastore#,[db, T_Entity01#]) as Datastore
		ds.upsert(entity)
		entity = ds.findOne([:])
		
		
		// Mongo types
		verifyEq(entity.float, 		69f)
		verifyEq(entity.str, 		"string")
		verifyEq(entity.doc["wot"],	"ever")
		verifyEq(entity.list[0], 	"wot")
		verifyEq(entity.list[1], 	"ever")
		verifyEq(entity.binaryMd5.subtype,			Binary.BIN_MD5)
		verifyEq(entity.binaryMd5.data.readAllStr,	"dragon")
		verifyEq(entity.binaryOld.subtype,			Binary.BIN_BINARY_OLD)
		verifyEq(entity.binaryOld.data.readAllStr,	"dragon")
		verifyEq(entity.binaryBuf.readAllStr,		"vampire")
		verifyEq(entity.objectId, 	objId)
		verifyEq(entity.bool, 		true)
		verifyEq(entity.dateTime,	now)
		verifyEq(entity.nul, 		null)
		verifyEq(entity.regex, 		"2 problems".toRegex)
		verifyEq(entity.code.code,	"func() { ... }")
		verifyEq(entity.code.scope, [Str:Obj?][:])
		verifyEq(entity.codeScope.code,	"func() { ... }")
		verifyEq(entity.codeScope.scope,	Str:Obj?["wot":"ever"])
		verifyEq(entity.timestamp,	Timestamp(3sec, 69))
		verifyEq(entity.int,		999)
		verifyEq(entity.minKey,		MinKey())
		verifyEq(entity.maxKey,		MaxKey())
		
		// Fantom types
		verifyEq(entity.date, 		Date.today)	
		verifyEq(entity.enumm,		T_Entity01_Enum.wot)
		verifyEq(entity.uri,		`http://uri/`)
		verifyEq(entity.decimal,	6.9d)
		verifyEq(entity.duration,	3sec)
		verifyEq(entity.type,		MorphiaTest#)
		verifyEq(entity.slot,		MorphiaTest#setup)
		verifyEq(entity.range,		2..<4)
		verifyEq(entity.map[3],		T_Entity01_Enum.ever)
	}
}
