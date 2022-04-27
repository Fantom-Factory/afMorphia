    using afBson::ObjectId
    //using afMorphia::Morphia
    
    @Entity
    class User {
        @BsonProp ObjectId   _id
        @BsonProp Str        name
        @BsonProp Int        age
    
        new make(|This|in) { in(this) }
    }
    
    class Example {
    
        Void main() {
            morphia   := Morphia(`mongodb://localhost:27017/exampledb`) 
            datastore := morphia.datastore(User#)
            
            micky := User {
                it._id  = ObjectId()
                it.age  = 42
                it.name = "Micky Mouse"
            }
    
            // ---- Create ------
            datastore.insert(micky)
    
            // ---- Read --------
            mouse := (User) datastore.findOne(true) {
                it->age = 42
            }
            echo(mouse.name)  // --> Micky Mouse
    
            // ---- Update -----
            mouse.name = "Minny Mouse"
            datastore.update(mouse)
    
            // ---- Delete ------
            datastore.delete(micky)
    
            morphia.shutdown
        }
    }
