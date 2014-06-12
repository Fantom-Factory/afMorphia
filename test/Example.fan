using afBson
//using afMorphia
using afIoc
using afIocConfig

@Entity
internal 
class User {
	@Property ObjectId	_id
	@Property Name		name
	@Property Int		age
	
	new make(|This|in) { in(this) }
}

internal 
class Name {
    @Property Str  firstName
    @Property Str  lastName
    new make(|This|in) { in(this) }
}

internal 
class Example {

	@DatastoreType { type=User# } 
	@Inject Datastore? datastore

	Void main() {
		reg := RegistryBuilder().addModulesFromPod(Pod.find("afMorphia")).addModule(ExampleModule#).build.startup
		reg.injectIntoFields(this)
		
		micky := User { 
			it._id 	= ObjectId()
			it.age	= 42
			it.name = Name {
				it.firstName = "Micky"
				it.lastName  = "Mouse"
			}
		}
		
		// ---- Create ------
		datastore.insert(micky)
		
		// ---- Read --------
		mouse := (User) datastore.findOne(["age": 42])
		echo(mouse.name)  // --> Micky Mouse
		echo(datastore.toMongoDoc(mouse))
		
		// ---- Update -----
		mouse.name.firstName = "Minny"
		datastore.update(mouse)
		
		// ---- Delete ------
		datastore.delete(micky)
		
		reg.shutdown
	}
}

internal 
class ExampleModule {
	@Contribute { serviceType=ApplicationDefaults# }
	static Void contributeAppDefaults(MappedConfig config) {
		config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
	}

	@Contribute { serviceType=Converters# }
	static Void contributeConverters(MappedConfig config) {
		config[Name#] = NameConverter()
	}
}

internal 
const class NameConverter : Converter {

	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		if (mongoObj == null) return null
		mong := ((Str) mongoObj).split('-')
		return Name { it.firstName = mong[0]; it.lastName = mong[1] }
	}
	
	override Obj? toMongo(Obj fantomObj) {
		name := (Name) fantomObj
		return "${name.firstName}-${name.lastName}"
	}
}
