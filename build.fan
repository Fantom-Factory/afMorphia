using build

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB object mapping library"
		version = Version("1.2.4")

		meta = [
			"pod.dis"		: "Morphia",
			"afIoc.module"	: "afMorphia::MorphiaModule",
			"repo.tags"		: "database",
			"repo.public"	: "true"
		]

		index	= [	"afIoc.module"	: "afMorphia::MorphiaModule" ]

		depends = [
			"sys        1.0.69 - 1.0", 
			"concurrent 1.0.69 - 1.0",	// for contributing an ActorPool 
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.18 - 1.0",
			"afIoc        3.0.0  - 3.0",
			"afIocConfig  1.1.0  - 1.1",

			// ---- Mongo -----------------------
			"afBson  1.1.0 - 1.1",
			"afMongo 1.1.8 - 1.1",
		]
		
		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/converters/`, `fan/public/`, `fan/public/services/`, `test/`, `test/db-tests/`, `test/unit-tests/`, `test/unit-tests/converters/`]
		resDirs = [`doc/`]
	}
}
