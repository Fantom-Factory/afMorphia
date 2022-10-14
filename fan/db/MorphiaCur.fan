using afBson::BsonIO
using afMongo::MongoCur

** Morphio Cursors wrap Mongo cursors to return entity objects.
class MorphiaCur {
	
	** The backing Mongo cursor.
	MongoCur mongoCur {
		private set
	}
	
	** The Fantom type that objects are returned as.
	Type type
	
	** Used to convert BSON documents to Fantom objects.
	BsonConvs bsonConvs
	
	** Creates a new Morphia Cursor.
	new make(MongoCur mongoCur, Type type, BsonConvs bsonConvs) {
		this.mongoCur	= mongoCur
		this.type		= type
		this.bsonConvs	= bsonConvs
	}
	
	** Returns the next entity from the cursor, or 'null'.
	** 
	** The cursor must be manually killed.
	** 
	** pre>
	** syntax: fantom
	** 
	** while (cursor.isAlive) {
	**     entity := cursor.next
	**     ...
	** }
	** cursor.kill
	** <pre
	Obj? next() {
		doc := mongoCur.next
		return doc == null ? null : bsonConvs.fromBsonDoc(doc, type)
	}
	
	** Kills this cursor.
	** 
	** No more entities will be returned from 'next()', 'each()', or 'toList()'.
	Void kill() {
		mongoCur.kill
	}

	** Iterates over all *remaining* and unread documents.
	** 
	** This cursor is guaranteed to be killed.
	** 
	** pre>
	** syntax: fantom
	** 
	** cursor.each |Obj entity, Int index| {
	**     ...
	** }
	** <pre
	Void each(|Obj doc, Int index| fn) {
		mongoCur.each |doc, i| {
			ent := bsonConvs.fromBsonDoc(doc, type)
			fn(ent, i)
		}
	}

	** Converts all *remaining* and unread documents to a List.
	** The new list is typed based on the return type of the function.
	** 
	** This cursor is guaranteed to be killed.
	** 
	** pre>
	** syntax: fantom
	** 
	** list := cursor.map |Obj entity, Int index -> Obj?| {
	**     ...
	** }
	** <pre
	Obj?[] map(|Obj ent, Int index->Obj?| fn) {
		type := fn.returns == Void# ? Obj?# : fn.returns
		list := List.make(type, 16)
		mongoCur.each |doc, i| {
			ent := bsonConvs.fromBsonDoc(doc, type)
			obj := fn(ent, i)
			list.add(obj)
		}
		return list
	}

	** Return all *remaining* and unread entities as a List.
	** 
	** This cursor is guaranteed to be killed.
	Obj[] toList() {
		list := List.make(type, 16)
		mongoCur.each |doc, i| {
			ent := bsonConvs.fromBsonDoc(doc, type)
			list.add(ent)
		}
		return list
	}
	
	** Returns 'true' if the cursor is alive on the server or more documents may be read.
	Bool isAlive() {
		mongoCur.isAlive
	}

	@NoDoc
	override Str toStr() { mongoCur.toStr }
}
