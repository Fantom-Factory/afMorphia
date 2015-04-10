#Morphia v1.0.2
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.0.2](http://img.shields.io/badge/pod-v1.0.2-yellow.svg)](http://www.fantomfactory.org/pods/afMorphia)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

`Morphia` is a Fantom to MongoDB object mapping library.

`Morphia` is an extension to the [Mongo](http://www.fantomfactory.org/pods/afMongo) library that maps Fantom objects and their fields to and from MongoDB collections and documents.

`Morphia` features include:

- All Fantom literals and [BSON](http://www.fantomfactory.org/pods/afBson) types supported by default,
- Support for embedded / nested Fantom objects,
- Extensible mapping - add custom Fantom <-> Mongo converters,
- Query Builder API.

Note: `Morphia` has no association with [Morphia - the Java to MongoDB mapping library](https://github.com/mongodb/morphia/wiki). Well, except for the name of course!

## Install

Install `Morphia` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afMorphia

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afMorphia 1.0"]

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
    @Inject { type=User# }
    Datastore? datastore

    Void main() {
        reg := RegistryBuilder().addModule(ExampleModule#).addModulesFromPod("afMorphia").build.startup
        reg.injectIntoFields(this)

        micky := User {
            it._id  = ObjectId()
            it.name = "Micky Mouse"
            it.age  = 42
        }

        // ---- Create ------
        datastore.insert(micky)

        // ---- Read --------
        q     := Query().field("age").eq(42)
        mouse := (User) datastore.query(q).findOne
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
              |___|1.0.0

Connected to MongoDB v2.6.5 (at mongodb://localhost:27017)

[afIoc]
   ___    __                 _____        _
  / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
 / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
/_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
                            Alien-Factory IoC v2.0.2 /___/

IoC Registry built in 355ms and started up in 225ms

Micky Mouse

[afIoc] IoC shutdown in 12ms
[afIoc] "Goodbye!" from afIoc!
```

## Usage

### MongoDB Connections

A [Mongo Connection URL](http://docs.mongodb.org/manual/reference/connection-string/) should be contributed as an application default. This supplies the default database to connect to, along with any default user credentials. Example, in your `AppModule`:

```
@Contribute { serviceType=ApplicationDefaults# }
static Void contributeAppDefaults(Configuration config) {
    config[MorphiaConfigIds.mongoUrl] = `mongodb://username:password@localhost:27017/exampledb`
}
```

`Morphia` uses the connection URL to create a pooled [ConnectionManager](http://repo.status302.com/doc/afMongo/ConnectionManagerPooled.html). The `ConnectionManager`, and all of its connections, are gracefully closed when IoC / BedSheet is shutdown.

Some connection URL options are supported:

- `mongodb://username:password@example1.com/database?maxPoolSize=50`
- `mongodb://example2.com?minPoolSize=10&maxPoolSize=25`

See [ConnectionManagerPooled](http://repo.status302.com/doc/afMongo/ConnectionManagerPooled.html) for more details.

### Entities

An entity is a top level domain object that is persisted in a MongoDB collection.

Entity objects must be annotated with the [@Entity](http://repo.status302.com/doc/afMorphia/Entity.html) facet. By default the MongoDB collection name is the same as the (unqualified) entity type name. Example, if your entity type is `acmeExample::User` then it maps to a Mongo collection named `User`. This may be overriden by providing a value for the `@Entity.name` attribute.

Entity fields are mapped to properties in a MongoDB document. Use the `@Property` facet to mark fields that should be mapped to / from a Mongo property. Again, the default is to take the property name and type from the field, but it may be overridden by facet values.

As all MongoDB documents define a unique property named `_id`, all entities must also define a unique property named `_id`. Example:

    @Entity
    class MyEntity {
        @Property
        ObjectId _id
        ...
    }

or

    @Entity { name="AnotherEntity" }
    class MyEntity {
        @Property { name="_id" }
        ObjectId wotever
        ...
    }

Note that a Mongo Id *does not* need to be an `ObjectId`. Any object may be used, it just needs to be unique.

### Datastore

A [Datastore](http://repo.status302.com/doc/afMorphia/Datastore.html) wraps a [Mongo Collection](http://repo.status302.com/doc/afMongo/Collection.html) and is your gateway to saving and reading Fantom objects to / from the MongoDB.

Each `Datastore` instance is specific to an Entity type, so to inject a `Datastore` you need to specify which Entity it is associated with. Use the `@Inject.type` attribute to do this. Example:

    @Inject { type=User# }
    Datastore userDatastore

You can also inject Mongo `Collections` in the same manner:

    @Inject { type=User# }
    Collection userCollection

## Mapping

At the core of `Morphia` is a suite of [Converters](http://repo.status302.com/doc/afMorphia/Converter.html) that map Fantom objects to Mongo documents.

### Standard Converters

By default, `Morphia` provides support and converters for the following Fantom types:

```
afBson::Binary
   sys::Bool
   sys::Buf
afBson::Code
   sys::Date
   sys::DateTime
   sys::Decimal
   sys::Depend
   sys::Duration
   sys::Enum
   sys::Field
   sys::Float
   sys::Int
   sys::List
   sys::Locale
   sys::Map
afBson::MaxKey
   sys::Method
   sys::MimeType
afBson::MinKey
        null
afBson::ObjectId
   sys::Regex
   sys::Range
   sys::Slot
   sys::Str
   sys::Time
   sys::TimeZone
afBson::Timestamp
   sys::Type
   sys::Unit
   sys::Uri
   sys::Uuid
   sys::Version
```

### Embedded Objects

Morphia is also able to convert embedded, or nested, Fantom objects. Extending the example in [Quick Start](#quickStart), here we substitute the `Str` name for an embedded `Name` object:

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

If you want to store `null` values, then create a new `ObjConverter` passing `true` into the ctor, and contribute it in your AppModule: Example:

```
@Contribute { serviceType=Converters# }
static Void contributeConverters(Configuration config) {
    config.overrideValue(Obj#, config.createProxy(Converter#, ObjConverter#,  [true]), "MyObjConverter")
}
```

(A proxy is required due to the circular nature of Converters.)

See [Storing null vs not storing the key at all in MongoDB](http://stackoverflow.com/questions/12403240/storing-null-vs-not-storing-the-key-at-all-in-mongodb) for more details.

## Query API

Querying a MongoDB for documents requires knowledge of their [Query Operators](http://docs.mongodb.org/manual/reference/operator/query/). While simple for simple queries:

    query := ["age": 42]

It can quickly grow unmanagable and confusing for larger queries. For example, this tangled mess is from the official documentation for the [$and operator](http://docs.mongodb.org/manual/reference/operator/query/and/):

```
query := [
    "\$and" : [
        ["\$or": [["price": 0.99f], ["price": 1.99f]]],
        ["\$or": [["sale" : true ], ["qty"  : ["\$lt": 20]]]]
    ]
]
```

For that reason Morphia provides a means to build and execute [Query](http://repo.status302.com/doc/afMorphia/Query.html) objects that rely on more meaningful method names. The simple example may be re-written as:

    query := Query().field("age").eq(42)

Use a [QueryExecutor](http://repo.status302.com/doc/afMorphia/QueryExecutor.html) as returned from the `Datastore.query(...)` method to run the query.

    datastore.query(query).findAll

Because you often create `Query` objects to match fields, it can be helpful to squirrel away this little bit of code in its own method:

    QueryCriterion field(Str fieldName) {
        Query().field(fieldName)
    }

The more complicated `$and` example then becomes:

    query := Query().and([
        Query().or([ field("price").eq(0.99f), field("price").eq(1.99f)  ]),
        Query().or([ field("sale ").eq(true),  field("qty").lessThan(20) ])
    ])

Which, even though slightly more verbose, should be much easier to construct, understand, and debug. And the autocomplete nature of IDEs such as [F4](http://www.xored.com/products/f4/) means you don't have to constantly consult the [Mongo documentation](http://docs.mongodb.org/manual/reference/method/db.collection.find/).

## Testing

To use Morphia in unit testing, lay out the test class in a similar way to the QuickStart example:

```
using afMorphia::Datastore
using afMorphia::MorphiaConfigIds
using afIoc::Configuration
using afIoc::Contribute
using afIoc::Inject
using afIoc::Registry
using afIoc::RegistryBuilder
using afIocConfig::ApplicationDefaults

class TestExample : Test {
    Registry? reg

    @Inject { type=MyEntity# }
    Datastore? datastore

    override Void setup() {
        reg = RegistryBuilder()
                  .addModule(TestModule#)
                  .addModulesFromPod("afMorphia")
                  .addModulesFromPod("afIocConfig")
                  .build.startup
        reg.injectIntoFields(this)
    }

    override Void teardown() {
        // use elvis incase 'reg' was never set due to a startup Err
        // we don't want an NullErr in teardown() to mask the real problem
        reg?.shutdown
    }

    Void testStuff() {
        ...
        datastore.insert(...)
        ...
    }
}

class TestModule {
    @Contribute { serviceType=ApplicationDefaults# }
    static Void contributeAppDefaults(Configuration config) {
        config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
    }
}
```

The `setup()` method builds the IoC Registry, passing in a `TestModule` that defines the mongo connection url.

Note that because the registry is being built from scratch, you need to add modules from all the IoC libraries the test uses. Hence the example above adds modules for `afMorphia` and `afIocConfig`.

Should you fail to add a required module / library, the test will fail with an `IocErr`:

    TEST FAILED
    afIoc::IocErr: No service matches type XXXX.

Where `XXXX` is a service in the library you forgot to add.

Rather than create a specific `TestModule` for testing, you could just use your application's `AppModule` instead, subject to the BedSheet exception below.

### Testing in a BedSheet Web App

A standard `AppModule` for a BedSheet application **can not** be used in a Morphia unit test. That is because the `AppModule` will configure BedSheet and other web related services that aren't available in the Morphia unit test.

The strategy here is to split the `AppModule` into two, one that configures web services and another that just configures database services. Use IoC's `@SubModule` facet to reference one from the other.

```
** Configure BedSheet and other web services here
@SubModule { modules=[DatabaseModule#] }
class AppModule {
    ....
}

** Configure Morphia and other database services here
class DatabaseModule {

    @Contribute { serviceType=ApplicationDefaults# }
    static Void contributeAppDefaults(Configuration config) {
        config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
    }

    ...
}
```

Now you can just use the `DatabaseModule` in your Morphia tests. And when BedSheet loads `AppModule`, the `@SubModule` facet will ensure the `DatabaseModule` gets loaded too.

## Remarks

If you're looking for cross-platform MongoDB GUI client then look no further than [Robomongo](http://robomongo.org/)!

