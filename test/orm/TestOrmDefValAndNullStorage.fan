
internal class TestOrmDefValConversion : Test {

	BsonConvs? converters := BsonConvs()
	
	Void testDefValToMongo() {

		entity := T_Entity28() {
			markerFalse 	= false
			markerTrue 		= true
			intZero			= 0
			intOne			= 1
			emptyStrList	= Str[,]
			emptyIntList	= Int[,]
			emptyStrMap		= Str:Str[:]
			emptyIntMap		= Int:Int[:]
			strList			= Str    ["wot","ever"]
			strMap			= Str:Str["wot":"ever"]
			enumDef			= T_Entity13_Enum.wot
		}
		
		mongoDoc := converters.toBsonDoc(entity)
	echo(mongoDoc)	
		verifyEq(mongoDoc.size,	0)
	}

	Void testDefValToFantom() {
		// text non-exist
		mongoDoc := [:]
		entity := (T_Entity28) converters.fromBsonDoc(mongoDoc, T_Entity28#)
		verifyEq(entity.markerFalse,	false)
		verifyEq(entity.markerTrue, 	true)
		verifyEq(entity.intZero,		0)
		verifyEq(entity.intOne,			1)
		verifyEq(entity.emptyStrList,	Str[,])
		verifyEq(entity.emptyIntList,	Int[,])
		verifyEq(entity.emptyStrMap,	Str:Str[:])
		verifyEq(entity.emptyIntMap,	Int:Int[:])
		verifyEq(entity.strList,		["wot", "ever"])
		verifyEq(entity.strMap,			["wot": "ever"])
		verifyEq(entity.enumDef,		T_Entity13_Enum.wot)
		
		// text nulls
		mongoDoc = [
			"markerFalse"	: null,
			"markerTrue"	: null,
			"intZero"		: null,
			"intOne"		: null,
			"emptyStrList"	: null,
			"emptyIntList"	: null,
			"emptyStrMap"	: null,
			"emptyIntMap"	: null,
			"strList"		: null,
			"strMap"		: null,
			"enumDef"		: null,
		]
		entity = (T_Entity28) converters.fromBsonDoc(mongoDoc, T_Entity28#)
		verifyEq(entity.markerFalse,	false)
		verifyEq(entity.markerTrue, 	true)
		verifyEq(entity.intZero,		0)
		verifyEq(entity.intOne,			1)
		verifyEq(entity.emptyStrList,	Str[,])
		verifyEq(entity.emptyIntList,	Int[,])
		verifyEq(entity.emptyStrMap,	Str:Str[:])
		verifyEq(entity.emptyIntMap,	Int:Int[:])
		verifyEq(entity.strList,		["wot", "ever"])
		verifyEq(entity.strMap,			["wot": "ever"])
		verifyEq(entity.enumDef,		T_Entity13_Enum.wot)
	}
	
	Void testBadFitDefVal() {
		verifyErrMsg(Err#, "@BsonProp.defVal of type 'Str' does not fit field 'Bool afMorphia::T_Entity29.marker'") {
			converters.fromBsonDoc([:], T_Entity29#)
		}
	}
}

internal class T_Entity28 {
	@BsonProp { defVal=false		}	Bool	markerFalse
	@BsonProp { defVal=true			}	Bool	markerTrue
	@BsonProp { defVal=0			}	Int		intZero
	@BsonProp { defVal=1			}	Int		intOne
	@BsonProp { defVal=Str[,]		}	Str[]	emptyStrList
	@BsonProp { defVal=[,]			}	Int[]	emptyIntList
	@BsonProp { defVal=Str:Str[:]	}	Str:Str	emptyStrMap
	@BsonProp { defVal=[:]			}	Int:Int	emptyIntMap

	@BsonProp { defVal=["wot", "ever"]		}	Str[]	strList
	@BsonProp { defVal=["wot": "ever"]		}	Str:Str	strMap
	@BsonProp { defVal=T_Entity13_Enum.wot	}	T_Entity13_Enum enumDef

	new make(|This| in) { in(this) }
}

internal class T_Entity29 {
	@BsonProp { defVal="badfit"		}	Bool	marker
	new make(|This| in) { in(this) }
}
