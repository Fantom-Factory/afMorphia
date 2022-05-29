# Morphia v2.0.2
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v2.0.2](http://img.shields.io/badge/pod-v2.0.2-yellow.svg)](http://eggbox.fantomfactory.org/pods/afMorphia)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

Morphia is a Fantom to MongoDB object mapping library.

Morphia is an extension to the [Mongo](http://eggbox.fantomfactory.org/pods/afMongo) library that maps Fantom objects and their fields to and from MongoDB collections and BSON documents.

Morphia features include:

* All Fantom literals and [BSON](http://eggbox.fantomfactory.org/pods/afBson) types supported by default,
* Support for embedded / nested Fantom objects,
* Extensible mapping - add your own Fantom <-> Mongo converters,
* Optimistic locking support
* Cursor support


Note: Morphia has no association with [Morphia - the Java to MongoDB mapping library](https://github.com/mongodb/morphia/wiki). Well, except for the name of course!

## <a name="Install"></a>Install

Install `Morphia` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afMorphia

Or install `Morphia` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afMorphia

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afMorphia 2.0"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afMorphia/) - the Fantom Pod Repository.

## <a name="quickStart"></a>Quick Start

1. Start up an instance of MongoDB:    C:\> mongod
    
    MongoDB starting
    db version v5.2.0
    waiting for connections on port 27017


2. Create a text file called `Example.fan`    using afBson::ObjectId
    using afMorphia::Morphia
    
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


3. Run `Example.fan` as a Fantom script from the command line:    [afMongo] Found a new Master at mongodb://localhost:27017/exampledb
    [afMongo]
    
         Fantom-Factory
     _____ ___ ___ ___ ___
    |     | . |   | . | . |
    |_|_|_|___|_|_|_  |___|
                  |___|2.0.0
    
    Micky Mouse




## Usage

### MongoDB Connections

A [Mongo Connection URL](http://docs.mongodb.org/manual/reference/connection-string/) supplies the default database to connect to, along with any user credentials.

`Morphia` then uses the connection URL to create a pooled [MongoConnMgr](http://eggbox.fantomfactory.org/pods/afMongo/api/MongoConnMgr).

Some connection URL options are supported:

* `mongodb://username:password@example1.com/database?maxPoolSize=50`
* `mongodb://example2.com?minPoolSize=10&maxPoolSize=25`


See [ConnectionManagerPooled](http://eggbox.fantomfactory.org/pods/afMongo/api/MongoConnMgr) for more details.

### Entities

An entity is a top level domain object that is persisted in a MongoDB collection.

Entity objects must be annotated with the [@Entity](http://eggbox.fantomfactory.org/pods/afMorphia/api/Entity) facet. By default the MongoDB collection name is the same as the (unqualified) entity type name. Example, if your entity type is `acmeExample::User` then it maps to a Mongo collection named `User`. This may be overriden by providing a value for the `@Entity.name` attribute.

Entity fields are mapped to properties in a MongoDB document. Use the `@BsonProp` facet to mark fields that should be mapped to / from a Mongo property. Again, the default is to take the property name and type from the field, but it may be overridden by facet values.

As all MongoDB documents define a unique property named `_id`, all entities must also define a unique property named `_id`. Example:

    @Entity
    class MyEntity {
        @BsonProp
        ObjectId _id
        ...
    }

or

    @Entity { name="AnotherEntity" }
    class MyEntity {
        @BsonProp { name="_id" }
        ObjectId wotever
        ...
    }

Note that a Mongo Id *does not* need to be an `ObjectId`. Any object may be used, it just needs to be unique.

### Datastore

A [Datastore](http://eggbox.fantomfactory.org/pods/afMorphia/api/Datastore) wraps a [Mongo Collection](http://eggbox.fantomfactory.org/pods/afMongo/api/MongoColl) and is your gateway to saving and reading Fantom objects to / from the MongoDB.

Each `Datastore` instance is specific to an Entity type, so to create a `Datastore` you need to specify which Entity it is associated with.

    datastore := morhphia.datastore(User#)
    

## Mapping

At the core of `Morphia` is a suite of [Converters](http://eggbox.fantomfactory.org/pods/afMorphia/api/BsonConv) that map Fantom objects to BSON documents.

### Standard Converters

`Morphia` provides support and converters for the following Fantom types:

            null
    afBson::Binary
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
    

#### Map Key Restrictions

As detailed in [Restrictions on Field Names](http://docs.mongodb.org/manual/reference/limits/#Restrictions-on-Field-Names) MongoDB does not allow the characters `$` (dollar) and `.` (full stop) to be stored in Map keys. To overcome this limitation Morphia automatically encodes keys as unicode escape sequences, similar to how Java works. More specifically, the following characters are escaped:

    \uXXXX  -->  \uuXXXX
    $       -->  \u0024
    .       -->  \u002e
    

Hence the key `pod.$name-Om\u2126` would be stored as `pod\u002e\u0024name-Om\uu2126`.

Morphia automatically decodes Map keys when it reads them back from Mongo, so generally, the encoding / decoding process is of no concern. However, when constructing queries for such key values, it is something you need to be aware of.

### Embedded Objects

Morphia is also able to convert embedded, or nested, Fantom objects. Extending the example in [Quick Start](#quickStart), here we substitute the `Str` name for an embedded `Name` object:

    @Entity
    class User {
        @BsonProp ObjectId _id
        @BsonProp Name     name
        @BsonProp Int      age
        new make(|This|in) { in(this) }
    }
    
    class Name {
        @BsonProp Str  firstName
        @BsonProp Str  lastName
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
    mongoDoc := datastore.toBsonDoc(micky)
    
    echo(mongoDoc) // --> [_id:xxxx, age:42, name:[lastName:Mouse, firstName:Micky]]
    

Note that embedded Fantom types need *not* be annotated with `@Entity`. The Entity facet is reserved for top level objects only.

### Default Values

It is often desirable not to bloat out your database by storing common default values. Perhaps you have a `boolean` values that is rarely set, or a list that is usually empty? In such situations it can be advantageous to *NOT* store such values in the database.

To that end, you can set the `defVal` value on a field's `@BsonProp` facet.

    @BsonProp { defVal=false }
    Bool  marker
    
    @BsonProp { defVal=[,] }
    Str[] list
    

Should the field value equal this `defVal` then it is treated as if it is `null`, regardless of the field's type nullablity. This, combined with the default [null storage strategy](#storingNullsInMongo) result in the value *NOT* being stored.

When read back from the MongoDB any missing or `null` values are replaced with `defVal`.

### Mixed Inheritance

Sometimes you want to store a list of mixed embedded classes. Often the list is a mix of different implementations of a common superclass:

    @BsonProp
    SuperClass[] allMixedUp
    
    ...
    
    this.allMixedUp := SuperClass[
        SubClass1(),
        SubClass2()
    ]
    

This works fine when saving to MongoDb, but when reading the list back Morphia doesn't know which implementation class to create for each item.

To get round this, add a field called `_type` to `SubClassX` that stores the implementation type. Morphia will use this to determine which implementation type to create. The easiest way to do this is to just add the following to `SuperClass`:

    class SuperClass {
        @BsonProp
        Type _type := typeof
    
        ...
    }
    

### Custom Converters

If you want more control over how objects are mapped to and from Mongo, then contribute a custom converter. Do this by implementing `BsonConv` and pass it to `BsonConvs` when you constuct it.

Example, to store the `Name` object as a simple hyphenated string:

    using afMorphia::BsonConv
    using afMorphia::BsonConvCtx
    
    const class NameConverter : BsonConv {
    
        override Obj? toBsonVal(Obj? fantomObj, BsonConvCtx ctx) {
            // decide how you want to handle null values
            if (fantomObj == null) return null
    
            name := (Name) fantomObj
            return "${name.firstName}-${name.lastName}"
        }
    
        override Obj? fromBsonVal(Obj? bsonVal, BsonConvCtx ctx) {
            // decide how you want to handle null values
            if (bsonVal == null) return null
    
            vals := ((Str) bsonVal).split('-')
            return Name { it.firstName = vals[0]; it.lastName = vals[1] }
        }
    }
    

To see it in action:

    micky := User {
        it._id  = ObjectId()
        it.age  = 42
        it.name = Name {
          it.firstName = "Micky"
          it.lastName  = "Mouse"
        }
    }
    
    bsonConvs := BsonConvs(
        BsonConvs.defConvs {
            it[Name#] = NameConverter
        }
    )
    bsonDoc  := bsonConvs.toBsonDoc(micky)
    
    echo(mongoDoc) // --> [_id:xxxx, age:42, name:Micky-Mouse]
    

### <a name="storingNullsInMongo"></a>Storing Nulls in Mongo

When converting Fantom objects *to* Mongo, if a Fantom field has the value `null` should it store a key in the MongoDb with a `null` value, or should it not store the key at all?

To conserve storage space in MongoDB, by default, Morphia does not store the keys.

If you want to store `null` values, then pass an option to `BsonConvs`. Example:

    bsonConvs := BsonConvs(null, [
        "storeNullFields" : true
    ])
    

See the [BsonConvs ctor](http://eggbox.fantomfactory.org/pods/afMorphia/api/BsonConvs.make) and [Storing null vs not storing the key at all in MongoDB](http://stackoverflow.com/questions/12403240/storing-null-vs-not-storing-the-key-at-all-in-mongodb) for more details.

## Optimistic Locking

Think of the following scenario:

1. User A reads an entity
2. User B reads the same entity
3. User B saves their entity
4. User A saves their entity


Here, User A has just overwritten all User B's changes. To prevent this, Morphia supports optimistic locking.

Optimistic locking is where an entity has a special `_version` integer property which is incremented everytime an entity is saved. If you attempt to save an entity that has a different `_version` property to what's in the database (presumably because your entity is out of date) then Morphia throws an `OptimisticLockErr`.

To use, just define an `Int _version` field property on your top level entity:

    class SomeEntity {
    
        @BsonProp
        Int _version
    
        ...
    }
    

On a successful save. and if the field is non-const, `Datastore.update()` will increment the `_version` field on the entity so you may re-save it again without having to re-read it from the database.

## Remarks

If you're looking for cross-platform MongoDB GUI client then look no further than [Robomongo](http://robomongo.org/) / Robo 3T / Studio 3T Free!

