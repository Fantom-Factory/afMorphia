using build

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB object mapping library"
		version = Version("1.1.0")

		meta = [
			"proj.name"		: "Morphia",
			"afIoc.module"	: "afMorphia::MorphiaModule",
			"repo.tags"		: "database",
			"repo.public"	: "true"
		]

		index	= [	"afIoc.module"	: "afMorphia::MorphiaModule" ]

		depends = [
			"sys        1.0", 
			"concurrent 1.0",	// for contributing an ActorPool 
			"inet       1.0", 
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.12 - 1.0",
			"afIoc        3.0.0  - 3.0",
			"afIocConfig  1.1.0  - 1.1",

			// ---- Mongo -----------------------
			"afBson  1.0.0 - 1.0",
			"afMongo 1.0.6 - 1.0"
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/converters/`, `fan/public/`, `fan/public/services/`, `test/`, `test/db-tests/`, `test/unit-tests/`, `test/unit-tests/converters/`]
		resDirs = [`doc/`]
	}
}
