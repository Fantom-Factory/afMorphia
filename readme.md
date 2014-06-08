## Overview 

A Fantom to MongoDB mapping library.

## Install 

Install `Morphia` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afMorphia

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afMorphia 0.0+"]

## Documentation 

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afMorphia/).

## Quick Start 

```
Example here
```

## Usage 

Contribute Mongo connection URI

Inject Datastore

## Standard Converters 

Anything should be possible with afMongo, but here in Morphia land we enforce good strategies and best practices.

All entities should have an ID

Null Strategies

- Document Converter (to Mongo)
- List Converter (to Fantom) - 0 capacity
- Map Converter (to Fantom)

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

## Custom Converters 

