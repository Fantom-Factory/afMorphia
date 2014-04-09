using afIoc
using afMongo

const mixin Serialiser {
	
	abstract Obj fromMongoDoc(Type type, Str:Obj? mongoDoc)
	abstract Str:Obj? toMongoDoc(Obj entity)
	
	abstract Obj? toFantom(Type fantomType, Obj? mongoObj)
	abstract Obj? toMongo(Type fantomType, Obj? fantomObj)
}

const class SerialiserImpl : Serialiser {
	
	@Inject	private const Registry 		reg
	@Inject	private const Converters	converters

	new make(|This|in) { in(this) }

	
	override Obj fromMongoDoc(Type type, Str:Obj? mongoDoc) {
		toFantom(type, mongoDoc)
	}
	
	override Str:Obj? toMongoDoc(Obj entity) {
		toMongo(entity.typeof, entity)		
	}
	
	override Obj? toFantom(Type fantomType, Obj? mongoObj) {
		fantomVal	:= null
		
		converter	:= converters[fantomType]
		
		if (converter != null) {
			fantomVal = converter.toFantom(fantomType, mongoObj)
		}
		
		if (converter == null) {
			if (fantomType.hasFacet(Document#))	// TODO: Entity -> Entity mapping 
				throw MorphiaErr("Entity -> Entity mapping not yet supported")

			// an embedded document...
			if (mongoObj != null)
//				fantomVal = fromMongoDoc(fantomType, mongoObj)
				fantomVal = reg.autobuild(DocumentConverter#)->toFantom(fantomType, mongoObj)
		}
		
		return fantomVal
	}
	
	override Obj? toMongo(Type fantomType, Obj? fantomObj) {
		mongoVal	:= null

		converter	:= converters[fantomType]
		
		if (converter != null) {
			mongoVal = converter.toMongo(fantomType, fantomObj)
		}

		if (converter == null) {
			if (fantomType.hasFacet(Document#))	// TODO: Entity -> Entity mapping 
				throw MorphiaErr("Entity -> Entity mapping not yet supported")

			if (fantomObj != null)
//				mongoVal = toMongoDoc(fantomObj)
				mongoVal = reg.autobuild(DocumentConverter#)->toMongo(fantomType, fantomObj)
		}

		if (!isMongoLiteral(mongoVal))	// TODO: re-do mongo check
			throw MorphiaErr(Msgs.serializer_notMongoLiteral(mongoVal.typeof))

		return mongoVal
	}
	
	
	internal Str:Str logDoc(Str:Obj? document) {
		document.map |val->Str| {
			if (val == null)
				return "null"
			if (literals.contains(val.typeof.toNonNullable))
				return val.toStr
			return "..." 
		}
	}

	// TODO: move BSON literals and helper (isBson) methods to Mongo
	private static const Type[] literals	:= [Bool#, Buf#, Date#, DateTime#, Float#, Int#, List#, Map#, ObjectId#, Regex#, Str#]

	private Bool isMongoLiteralType(Type? type) {
		// TODO: recurse into lists & maps -> diff name, it's then not a literal!
		(type == null) ? true : literals.any { type.fits(it) } 		
	}

	private Bool isMongoLiteral(Obj? obj) {
		// TODO: recurse into lists & maps -> diff name, it's then not a literal!
		(obj == null) ? true : literals.any { obj.typeof.fits(it) }
	}
}
