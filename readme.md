#Morphia v1.2.2
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom-lang.org/)
[![pod: v1.2.2](http://img.shields.io/badge/pod-v1.2.2-yellow.svg)](http://www.fantomfactory.org/pods/afMorphia)
![Licence: ISC Licence](http://img.shields.io/badge/licence-ISC Licence-blue.svg)

## Overview

Morphia is a Fantom to MongoDB object mapping library.

Morphia is an extension to the [Mongo](http://eggbox.fantomfactory.org/pods/afMongo) library that maps Fantom objects and their fields to and from MongoDB collections and documents.

Morphia features include:

- All Fantom literals and [BSON](http://eggbox.fantomfactory.org/pods/afBson) types supported by default,
- Support for embedded / nested Fantom objects,
- Extensible mapping - add custom Fantom <-> Mongo converters,
- Query Builder API.

Note: Morphia has no association with [Morphia - the Java to MongoDB mapping library](https://github.com/mongodb/morphia/wiki). Well, except for the name of course!

## Install

Install `Morphia` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afMorphia

Or install `Morphia` with [fanr](http://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afMorphia

To use in a [Fantom](http://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afMorphia 1.2"]

## Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afMorphia/) - the Fantom Pod Repository.

## Quick Start

1. Start up an instance of MongoDB:

        C:\> mongod
        
        MongoDB starting
        db version v3.2.10
        waiting for connections on port 27017


2. Create a text file called `Example.fan`

        using afIocConfig::ApplicationDefaults
        using afBson::ObjectId
        using afMorphia
        using afIoc
        
        @Entity
        class User {
            @Property ObjectId   _id
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
                    it._id  = ObjectId()
                    it.age  = 42
                    it.name = "Micky Mouse"
                }
        
                // ---- Create ------
                datastore.insert(micky)
        
                // ---- Read --------
                q     := Query().field(User#age).eq(42)
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


3. Run `Example.fan` as a Fantom script from the command line:

        [afIoc] Adding module Example_0::ExampleModule
        [afIoc] Adding module definitions from pod 'afMorphia'
        [afIoc] Adding module afMorphia::MorphiaModule
        [afIoc] Adding module afConcurrent::ConcurrentModule
        [afIoc] Adding module afIocConfig::IocConfigModule
        [afMongo]
        
             Alien-Factory
         _____ ___ ___ ___ ___
        |     | . |   | . | . |
        |_|_|_|___|_|_|_  |___|
                      |___|1.1.0
        
        Connected to MongoDB v3.2.10 (at mongodb://localhost:27017)
        
        [afIoc]
           ___    __                 _____        _
          / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
         / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
        /_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
                                    Alien-Factory IoC v3.0.4 /___/
        
        IoC Registry built in 81ms and started up in 205ms
        
        Micky Mouse
        
        [afIoc] IoC shutdown in 12ms
        [afIoc] "Goodbye!" from afIoc!



## Usage

### MongoDB Connections

A [Mongo Connection URL](http://docs.mongodb.org/manual/reference/connection-string/) should be contributed as an application default. This supplies the default database to connect to, along with any default user credentials.

To do so, create a `config.props` file in the root directory of your application:

    afMorphia.mongoUrl = mongodb://username:password@localhost:27017/exampledb

Or you can add the contribution in your `AppModule`:

```
@Contribute { serviceType=ApplicationDefaults# }
static Void contributeAppDefaults(Configuration config) {
    config[MorphiaConfigIds.mongoUrl] = `mongodb://username:password@localhost:27017/exampledb`
}
```

`Morphia` uses the connection URL to create a pooled [ConnectionManager](http://eggbox.fantomfactory.org/pods/afMongo/api/ConnectionManagerPooled). The `ConnectionManager`, and all of its connections, are gracefully closed when IoC / BedSheet is shutdown.

Some connection URL options are supported:

- `mongodb://username:password@example1.com/database?maxPoolSize=50`
- `mongodb://example2.com?minPoolSize=10&maxPoolSize=25`

See [ConnectionManagerPooled](http://eggbox.fantomfactory.org/pods/afMongo/api/ConnectionManagerPooled) for more details.

### Entities

An entity is a top level domain object that is persisted in a MongoDB collection.

Entity objects must be annotated with the [@Entity](http://eggbox.fantomfactory.org/pods/afMorphia/api/Entity) facet. By default the MongoDB collection name is the same as the (unqualified) entity type name. Example, if your entity type is `acmeExample::User` then it maps to a Mongo collection named `User`. This may be overriden by providing a value for the `@Entity.name` attribute.

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

A [Datastore](http://eggbox.fantomfactory.org/pods/afMorphia/api/Datastore) wraps a [Mongo Collection](http://eggbox.fantomfactory.org/pods/afMongo/api/Collection) and is your gateway to saving and reading Fantom objects to / from the MongoDB.

Each `Datastore` instance is specific to an Entity type, so to inject a `Datastore` you need to specify which Entity it is associated with. Use the `@Inject.type` attribute to do this. Example:

    @Inject { type=User# }
    Datastore userDatastore

You may also inject Mongo `Collections` in the same manner:

    @Inject { type=User# }
    Collection userCollection

## Mapping

At the core of `Morphia` is a suite of [Converters](http://eggbox.fantomfactory.org/pods/afMorphia/api/Converter) that map Fantom objects to Mongo documents.

### Standard Converters

By default, `Morphia` provides support and converters for the following Fantom types:

```
        null
afBson::Binary
afBson::Code
afBson::MaxKey
afBson::MinKey
afBson::ObjectId
afBson::Timestamp
   sys::Bool
   sys::Buf
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
   sys::Method
   sys::MimeType
   sys::Regex
   sys::Range
   sys::Slot
   sys::Str
   sys::Time
   sys::TimeZone
   sys::Type
   sys::Unit
   sys::Uri
   sys::Uuid
   sys::Version
```

#### Map Key Restrictions

As detailed in [Restrictions on Field Names](http://docs.mongodb.org/manual/reference/limits/#Restrictions-on-Field-Names) MongoDB does not allow the characters `$` (dollar) and `.` (full stop) to be stored in Map keys. To overcome this limitation Morphia automatically encodes keys as unicode escape sequences, similar to how Java works. More specifically, the following characters are escaped:

```
\uXXXX  -->  \uuXXXX
$       -->  \u0024
.       -->  \u002e
```

Hence the key `pod.$name-Om\u2126` would be stored as `pod\u002e\u0024name-Om\uu2126`.

Morphia automatically decodes Map keys when it reads them back from Mongo, so generally, the encoding / decoding process is of no concern. However, when constructing queries for such key values, it is something you need to be aware of.

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

Note that embedded Fantom types need *not* be annotated with `@Entity`. The Entity facet is reserved for top level objects only.

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

    override Obj? toMongo(Type fantomType, Obj? fantomObj) {
        // decide how you want to handle null values
        if (fantomObj == null) return null

        name := (Name) fantomObj
        return "${name.firstName}-${name.lastName}"
    }
}
```

Then contribute it in your AppModule:

```
@Contribute { serviceType=Converters# }
Void contributeConverters(Configuration config) {
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

### Mixed Inheritance

Sometimes you want to store a list of mixed embedded classes. Often the list is a mix of different implementations of a common superclass:

```
@Property
SuperClass[] allMixedUp

...

allMixedUp := SuperClass[
    SubClass1(),
    SubClass2()
]
```

This works fine when saving to MongoDb, but when reading the list back Morphia doesn't know which implementation class to create for each item.

To get round this, you could create your own converter class for `SuperClass` which determines which implementation to create.

Or, you could add a `@Property` to the items called `_type` that stores the implementation type. Morphia will then use this to determine which implementation type to create. The easiest way to do this is to just add the following to `SuperClass`:

```
@Property
Type _type := typeof
```

### Storing Nulls in Mongo

When converting Fantom objects *to* Mongo, the `ObjConverter` decides what to do if a Fantom field has the value `null`. Should it store a key in the MongoDb with a `null` value, or should it not store the key at all?

To conserve storage space in MongoDB, by default `ObjConverter` does not store the keys.

If you want to store `null` values, then create a new `ObjConverter` passing `true` into the ctor, and contribute it in your AppModule: Example:

```
@Contribute { serviceType=Converters# }
Void contributeConverters(Configuration config) {
    config.overrideValue(Obj#, config.build(ObjConverter#,  [true]), "MyObjConverter")
}
```

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

For that reason Morphia provides a means to build and execute [Query](http://eggbox.fantomfactory.org/pods/afMorphia/api/Query) objects that rely on more meaningful method names. The simple example may be re-written as:

    query := Query().field("age").eq(42)

Use a [QueryExecutor](http://eggbox.fantomfactory.org/pods/afMorphia/api/QueryExecutor) as returned from the `Datastore.query(...)` method to run the query.

    datastore.query(query).findAll

The more complicated `$and` example is then written as:

```
query := Query().and([
    Query().or([
        Query().field("price").eq(0.99f),
        Query().field("price").eq(1.99f)
    ]),
    Query().or([
        Query().field("sale" ).eq(true),
        Query().field("qty"  ).lessThan(20)
    ])
])
```

The [Queries](http://eggbox.fantomfactory.org/pods/afMorphia/api/Queries) mixin squirrels away common Query constructors into their own methods. Tip: Create a simple `q()` method to minimise code:

```
Queries q() { Queries() }

...

query := q.and([
    q.or([ q.eq("price", 0.99f), q.eq("price", 1.99f)  ]),
    q.or([ q.eq("sale", true),   q.lessThan("qty", 29) ])
])
```

Which is much easier to construct, understand, and debug. Plus the autocomplete nature of IDEs such as [F4](http://www.xored.com/products/f4/) means you don't have to constantly consult the [Mongo documentation](http://docs.mongodb.org/manual/reference/method/db.collection.find/)!

## Optimistic Locking

Think of the following scenario:

1. User A reads an entity
2. User B reads the same entity
3. User B saves their entity
4. User A saves their entity

Here, User A has just overwritten all User B's changes. To prevent this, Morphia supports optimistic locking.

Optimistic locking is where an entity has a special `_version` integer property which is incremented everytime an entity is saved. If you attempt to save an entity that has a different `_version` property to what's in the database (presumably because your entity is out of date) then Morphia throws an `OptimisticLockErr`.

To use, just define an `Int _version` field property on your top level entity:

```
@Property
Int _version
```

On a successful save. and if the field is non-const, `Datastore.update()` will increment the `_version` field on the entity so you may re-save it again without having to re-read it from the database.

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
                  .build.startup
        reg.activeScope.inject(this)
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

const class TestModule {
    @Contribute { serviceType=ApplicationDefaults# }
    Void contributeAppDefaults(Configuration config) {
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
const class AppModule {
    ....
}

** Configure Morphia and other database services here
const class DatabaseModule {

    @Contribute { serviceType=ApplicationDefaults# }
    Void contributeAppDefaults(Configuration config) {
        config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
    }

    ...
}
```

Now you can just use the `DatabaseModule` in your Morphia tests. And when BedSheet loads `AppModule`, the `@SubModule` facet will ensure the `DatabaseModule` gets loaded too.

## Remarks

If you're looking for cross-platform MongoDB GUI client then look no further than [Robomongo](http://robomongo.org/)!

