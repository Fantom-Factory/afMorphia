using afBson
//using afMorphia
using afIoc
using afIocConfig

@NoDoc
@Entity
class User {
	@Property ObjectId	_id
	@Property Str		name
	@Property Int		age
	
	new make(|This|in) { in(this) }
}

@NoDoc
class Example {

	@DatastoreType { type=User# } 
	@Inject Datastore? datastore

	Void main() {
		reg := RegistryBuilder().addModulesFromPod(Pod.find("afMorphia")).addModule(ExampleModule#).build.startup
		reg.injectIntoFields(this)
		
		micky := User { 
			it._id 	= ObjectId()
			it.name	= "Micky Mouse"
			it.age	= 42
		}
		
		// ---- Create ------
		datastore.insert(micky)
		
		// ---- Read --------
		mouse := (User) datastore.findOne(["age": 42])
		echo(mouse.name)  // --> Micky Mouse
		
		// ---- Update -----
		mouse.name = "Minny"
		datastore.update(mouse)
		
		// ---- Delete ------
		datastore.delete(micky)
		
		reg.shutdown
	}
}

@NoDoc
class ExampleModule {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(MappedConfig config) {
		config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
	}
}
