using build

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB mapping library"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Morphia",
			"afIoc.module"	: "afMorphia::MorphiaModule",
			"tags"			: "database",
			"repo.private"	: "true"
		]

		index	= [	"afIoc.module"	: "afMorphia::MorphiaModule" ]

		depends = [
			"sys 1.0", 
			"concurrent 1.0", 
			"inet 1.0", 
			
			"afBson 1.0.0+",
			"afMongo 0.0.2+",
			"afIoc 1.6.0+",
			"afIocConfig 1.0.6+"
		]
		
		srcDirs = [`test/unit-tests/`, `test/unit-tests/converters/`, `fan/`, `fan/public/`, `fan/public/services/`, `fan/internal/`, `fan/internal/converters/`]
		resDirs = [,]

		docApi = true
		docSrc = true
	}
}
