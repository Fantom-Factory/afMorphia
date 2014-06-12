using build

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB object mapping library"
		version = Version("0.0.3")

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
			"afMongo 0.0.4+",
			
			"afConcurrent 1.0.4+",
			"afBeanUtils 0.0.4+",
			"afIoc 1.6.2+",
			"afIocConfig 1.0.6+"
		]
		
		srcDirs = [`test/`, `test/unit-tests/`, `test/unit-tests/converters/`, `test/db-tests/`, `fan/`, `fan/public/`, `fan/public/services/`, `fan/internal/`, `fan/internal/converters/`]
		resDirs = [,]
	}
}
