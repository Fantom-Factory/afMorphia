using build

class Build : BuildPod {

	new make() {
		podName = "afMorphia"
		summary = "A Fantom to MongoDB mapping library."
		version = Version("0.0.1")

		meta = [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Morphia",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afMorphia",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afmorphia",
			"license.name"	: "MIT Licence",	
			"repo.private"	: "true"

			,"afIoc.module"	: "afMorphia::MorphiaModule"
		]


		index	= [	"afIoc.module"	: "afMorphia::MorphiaModule" ]


		depends = [
			"sys 1.0", 
			
			"afMongo 0+",
			"afIoc 1.5.5+"
		]
		
		srcDirs = [`test/unit-tests/`, `fan/`, `fan/public/`, `fan/public/services/`, `fan/internal/`, `fan/internal/utils/`, `fan/internal/converters/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true

		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
		resDirs = resDirs.exclude { it.toStr.startsWith("test/") }
	}
}
