    using afIocConfig::ApplicationDefaults
    using afBson::ObjectId
    using afMorphia
    using afIoc
    
    @Entity
    class User {
        @Property ObjectId    _id
        @Property Str        name
        @Property Int        age
        
        new make(|This|in) { in(this) }
    }
    
    class Example {
    
        @Inject { type=User# } 
        Datastore? datastore
    
        Void main() {
            reg := RegistryBuilder()
                    .addModule(ExampleModule#)
                    .addModulesFromPod("afMorphia")
                    .build
            reg.activeScope.inject(this)
            
            micky := User { 
                it._id     = ObjectId()
                it.age    = 42
                it.name = "Micky Mouse"
            }
            
            // ---- Create ------
            datastore.insert(micky)
            
            // ---- Read --------
            q     := Query().field("age").eq(42)
            mouse := (User) datastore.query(q).findOne
            echo(mouse.name)  // --> Micky Mouse
            
            // ---- Update -----
            mouse.name = "Minny Mouse"
            datastore.update(mouse)
            
            // ---- Delete ------
            datastore.delete(micky)
            
            reg.shutdown
        }
    }
    
    const class ExampleModule {
        @Contribute { serviceType=ApplicationDefaults# }
        static Void contributeAppDefaults(Configuration config) {
            config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
        }
    }
    