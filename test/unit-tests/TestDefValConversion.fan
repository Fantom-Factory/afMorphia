using afIoc::Inject
using afBson

internal class TestDefValConversion : MorphiaTest {

	@Inject Converters? converters
	
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
			enumDef			= T_Entity01_Enum.wot
		}
		
		mongoDoc := converters.toMongo(T_Entity28#, entity) as Map
		
		verifyEq(mongoDoc.size,	0)
	}

	Void testDefValToFantom() {
		// text non-exist
		mongoDoc := [:]
		entity := (T_Entity28) converters.toFantom(T_Entity28#, mongoDoc)
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
		verifyEq(entity.enumDef,		T_Entity01_Enum.wot)

		
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
		entity = (T_Entity28) converters.toFantom(T_Entity28#, mongoDoc)
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
		verifyEq(entity.enumDef,		T_Entity01_Enum.wot)
	}
	
	Void testBadFitDefVal() {
		verifyErrMsg(MorphiaErr#, "MongoDB document property 'marker' of type 'Str' does not fit field afMorphia::T_Entity29.marker of type 'Bool' : [:]") {
			converters.toFantom(T_Entity29#, [:])
		}
	}
}

@Entity
internal class T_Entity28 {
	@Property { defVal=false		}	Bool	markerFalse
	@Property { defVal=true			}	Bool	markerTrue
	@Property { defVal=0			}	Int		intZero
	@Property { defVal=1			}	Int		intOne
	@Property { defVal=Str[,]		}	Str[]	emptyStrList
	@Property { defVal=[,]			}	Int[]	emptyIntList
	@Property { defVal=Str:Str[:]	}	Str:Str	emptyStrMap
	@Property { defVal=[:]			}	Int:Int	emptyIntMap

	@Property { defVal=["wot", "ever"]		}	Str[]	strList
	@Property { defVal=["wot": "ever"]		}	Str:Str	strMap
	@Property { defVal=T_Entity01_Enum.wot	}	T_Entity01_Enum enumDef

	new make(|This| in) { in(this) }
}

@Entity
internal class T_Entity29 {
	@Property { defVal="badfit"		}	Bool	marker
	new make(|This| in) { in(this) }
}
