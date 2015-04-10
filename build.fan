using build

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB object mapping library"
		version = Version("1.0.4")

		meta = [
			"proj.name"		: "Morphia",
			"afIoc.module"	: "afMorphia::MorphiaModule",
			"tags"			: "database",
			"repo.private"	: "false"
		]

		index	= [	"afIoc.module"	: "afMorphia::MorphiaModule" ]

		depends = [
			"sys        1.0", 
			"concurrent 1.0",	// for contributing an ActorPool 
			"inet       1.0", 
			
			// ---- Core ------------------------
			"afConcurrent 1.0.8  - 1.0",
			"afBeanUtils  1.0.4  - 1.0",
			"afIoc        2.0.2  - 2.0",
			"afIocConfig  1.0.16 - 1.0",

			// ---- Mongo -----------------------
			"afBson  1.0.0 - 1.0",
			"afMongo 1.0.0 - 1.0"
		]
		
		srcDirs = [`test/`, `test/unit-tests/`, `test/unit-tests/converters/`, `test/db-tests/`, `fan/`, `fan/public/`, `fan/public/services/`, `fan/internal/`, `fan/internal/converters/`]
		resDirs = [,]
	}
}
