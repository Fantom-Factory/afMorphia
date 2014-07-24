## Overview 

`Morphia` is a Fantom to MongoDB object mapping library.

`Morphia` is an extension to the [Mongo](http://www.fantomfactory.org/pods/afMongo) library that maps Fantom objects and their fields to and from MongoDB collections and documents.

`Morphia` features include:

- All Fantom literals and [BSON](http://www.fantomfactory.org/pods/afBson) types supported by default,
- Support for embedded / nested Fantom objects,
- Extensible mapping - add your own custom [Converters](http://repo.status302.com/doc/afMorphia/Converters.html).

## Install 

Install `Morphia` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afMorphia

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afMorphia 0.0+"]

## Documentation 

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afMorphia/).

## Quick Start 

1). Start up an instance of MongoDB:

```
C:\> mongod

MongoDB starting
db version v2.6.0
waiting for connections on port 27017
```

2). Create a text file called `Example.fan`:

```
using afMorphia
using afBson
using afIoc
using afIocConfig

@Entity
class User {
    @Property ObjectId _id
    @Property Str      name
    @Property Int      age

    new make(|This|in) { in(this) }
}

class Example {
    @DatastoreType { type=User# }
    @Inject Datastore? datastore

    Void main() {
        reg := RegistryBuilder().addModulesFromPod(Pod.find("afMorphia")).addModule(ExampleModule#).build.startup
        reg.injectIntoFields(this)

        micky := User {
            it._id  = ObjectId()
            it.name = "Micky Mouse"
            it.age  = 42
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

class ExampleModule {
    @Contribute { serviceType=ApplicationDefaults# }
    static Void contributeAppDefaults(Configuration config) {
        config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
    }
}
```

3). Run `Example.fan` as a Fantom script from the command line:

```
[afIoc] Adding module definitions from pod 'afMorphia'
[afIoc] Adding module definition for afMorphia::MorphiaModule
[afIoc] Adding module definition for afIocConfig::IocConfigModule
[afIoc] Adding module definition for afMorphia::ExampleModule
[afMongo]

     Alien-Factory
 _____ ___ ___ ___ ___
|     | . |   | . | . |
|_|_|_|___|_|_|_  |___|
              |___|0.0.4

Connected to MongoDB v2.6.1 (at mongodb://localhost:27017)

[afIoc]
   ___    __                 _____        _
  / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
 / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
/_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
                            Alien-Factory IoC v1.6.2 /___/

IoC Registry built in 1,310ms and started up in 247ms

Micky Mouse
[afIoc] IoC shutdown in 12ms
[afIoc] "Goodbye!" from afIoc!
```

## Usage 

### Mongo Connection URL 

A [Mongo Connection URL](http://docs.mongodb.org/manual/reference/connection-string/) should be contributed as an application default. This supplies the default database to connect to, along with any default user credentials. Example, in your `AppModule`:

```
@Contribute { serviceType=ApplicationDefaults# }
static Void contributeAppDefaults(Configuration config) {
    config[MorphiaConfigIds.mongoUrl] = `mongodb://username:password@localhost:27017/exampledb`
}
```

### Entities 

An entity is a top level domain object that is persisted in a MongoDB collection.

Entity objects must be annotated with the [@Entity](http://repo.status302.com/doc/afMorphia/Entity.html) facet. By default, the MongoDB collection name is the same as the (unqualified) entity Type name. Example, if your entity type is `acmeExample::User` then it maps to a collection named `User`.

Entity fields are mapped to properties in a MongoDB document. Use the `@Property` facet to mark fields that should be mapped to / from a Mongo property. Again, the default is to take the property name and type from the field, but it may be overridden by facet values.

As all MongoDB documents define a unique property named `_id`, all entities must also define a unique property named `_id`. Example:

    @Entity
    class MyEntity {
        @Property
        ObjectId _id
        ...
    }

or

    @Entity
    class MyEntity {
        @Property { name="_id" }
        ObjectId wotever
        ...
    }

Note that a Mongo Id *does not* need to be an `ObjectId`. Any object may be used, it just needs to be unique.

### Datastore 

A [Datastore](http://repo.status302.com/doc/afMorphia/Datastore.html) wraps a [Mongo Collection](http://repo.status302.com/doc/afMongo/Collection.html) and is your gateway to reading and saving Fantom objects to the MongoDB.

Each `Datastore` instance is specific to an Entity type, so to Inject a `Datastore` you need to specify which Entity it is associated with. Use the `@DatastoreType` facet to do this. Example:

    @DatastoreType { type=User# }
    @Inject Datastore datastore

## Mapping 

At the core of `Morphia` is a suite of [Converters](http://repo.status302.com/doc/afMorphia/Converter.html) that map Fantom objects to Mongo documents.

### Standard Converters 

By default, `Morphia` provides converters for the following Fantom types:

```
afBson::Binary
   sys::Bool
   sys::Buf
afBson::Code
   sys::Date
   sys::DateTime
   sys::Decimal
   sys::Duration
   sys::Enum
   sys::Float
   sys::Int
   sys::List
   sys::Map
afBson::MaxKey
afBson::MinKey
        null
afBson::ObjectId
   sys::Regex
   sys::Range
   sys::Slot
   sys::Str
afBson::Timestamp
   sys::Type
   sys::Uri
```

### Embedded Objects 

Morphia is also able to convert embedded, or nested, Fantom objects. Extending the example in [Quick Start](http://repo.status302.com/doc/afMorphia/#quickStart.html), here we substitute the `Str` name for an embedded `Name` object:

```
@Entity
class User {
    @Property ObjectId _id
    @Property Name     name
    @Property Int      age
    new make(|This|in) { in(this) }
}

class Name {
    @Property Str  firstName
    @Property Str  lastName
    new make(|This|in) { in(this) }
}

...

micky := User {
    _id  = ObjectId()
    age  = 42
    name = name {
      firstName = "Micky"
      lastName  = "Mouse"
    }
}
mongoDoc := datastore.toMongoDoc(micky)

echo(mongoDoc) // --> [_id:xxxx, age:42, name:[lastName:Mouse, firstName:Micky]]
```

Note that embedded Fantom types should *not* be annotated with `@Entity`.

### Custom Converters 

If you want more control over how objects are mapped to and from Mongo, then contribute a custom converter. Do this by implementing `Converter` and contributing an instance to the `Converters` service.

Example, to store the `Name` object as a simple hyphenated string:

```
const class NameConverter : Converter {

    override Obj? toFantom(Type fantomType, Obj? mongoObj) {
        // decide how you want to handle null values
        if (mongoObj == null) return null

        mong := ((Str) mongoObj).split('-')
        return Name { it.firstName = mong[0]; it.lastName = mong[1] }
    }

    override Obj? toMongo(Obj fantomObj) {
        name := (Name) fantomObj
        return "${name.firstName}-${name.lastName}"
    }
}
```

Then contribute it in your AppModule:

```
@Contribute { serviceType=Converters# }
static Void contributeConverters(Configuration config) {
    config[Name#] = NameConverter()
}
```

To see it in action:

```
micky := User {
    it._id  = ObjectId()
    it.age  = 42
    it.name = Name {
      it.firstName = "Micky"
      it.lastName  = "Mouse"
    }
}
mongoDoc := datastore.toMongoDoc(micky)

echo(mongoDoc) // --> [_id:xxxx, age:42, name:Micky-Mouse]
```

### Storing Nulls in Mongo 

When converting Fantom objects *to* Mongo, the [ObjConverter](http://repo.status302.com/doc/afMorphia/ObjConverter.html) decides what to do if a Fantom field has the value `null`. Should it store a key in the MongoDb with a `null` value, or should it not store the key at all?

To conserve storage space in MongoDB, by default `ObjConverter` does not store the keys.

If you want to store `null` values, then create a new `ObjConverter` passing `false` into the ctor, and contribute it in your AppModule: Example:

```
@Contribute { serviceType=Converters# }
static Void contributeConverters(Configuration config) {
    config.overrideValue(Obj#,  config.registry.createProxy(Converter#, ObjConverter#,  [false]), null, "MyObjConverter")
}
```

(A proxy is required due to the circular nature of Converters.)

See [Storing null vs not storing the key at all in MongoDB](http://stackoverflow.com/questions/12403240/storing-null-vs-not-storing-the-key-at-all-in-mongodb) for more details.

