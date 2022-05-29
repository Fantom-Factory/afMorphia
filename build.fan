using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB object mapping library"
		version = Version("2.0.2")

		meta = [
			"pod.dis"		: "Morphia",
			"repo.tags"		: "database",
			"repo.public"	: "true"
		]

		depends = [
			"sys          1.0.71 - 1.0", 
			"concurrent   1.0.71 - 1.0",	// ActorPool for ConnMgr 
			
			// ---- Core ------------------------
			"afBeanUtils  1.0.8  - 1.0",
			"afConcurrent 1.0.18 - 1.0",

			// ---- Mongo -----------------------
			"afBson       2.0.2  - 2.0",
			"afMongo      2.1.0  - 2.1",
		]
	
		srcDirs = [`fan/`, `fan/db/`, `fan/orm/`, `fan/orm/advanced/`, `fan/orm/internal/`, `fan/orm/internal/converters/`, `test/`, `test/db/`, `test/orm/`]
		resDirs = [`doc/`]
	}
}
