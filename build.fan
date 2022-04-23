using build

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB object mapping library"
		version = Version("1.3.0")

		meta = [
			"pod.dis"		: "Morphia",
			"afIoc.module"	: "afMorphia::MorphiaModule",
			"repo.tags"		: "database",
			"repo.public"	: "true"
		]

//		index	= [	"afIoc.module"	: "afMorphia::MorphiaModule" ]

		depends = [
			"sys        1.0.71 - 1.0", 
			"concurrent 1.0.71 - 1.0",	// for contributing an ActorPool 
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.18 - 1.0",

			// ---- Mongo -----------------------
			"afBson  2.0.0 - 2.0",
			"afMongo 1.2.0 - 1.2",
		]
		
		srcDirs = [`fan/`, `fan/db/`, `fan/orm/`, `fan/orm/advanced/`, `fan/orm/internal/`, `fan/orm/internal/converters/`, `test/`, `test/orm/`]
		resDirs = [`doc/`]
	}
}
