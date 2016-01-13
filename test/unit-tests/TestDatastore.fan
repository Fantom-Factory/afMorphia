using afIoc

internal class TestDatastore : MorphiaTest {
	
	Void testEntityType() {
		verifyErrMsg(IocErr#, ErrMsgs.datastore_entityFacetNotFound(T_Entity09#)) {
			ds := scope.build(Datastore#, [T_Entity09#])
		}
	}

	Void testDatabaseName() {
		ds := (Datastore) scope.build(Datastore#, [T_Entity10#])
		verifyEq(ds.name, "T_Entity10")

		ds = (Datastore) scope.build(Datastore#, [T_Entity11#])
		verifyEq(ds.name, "Dude")
	}

	Void testFindId() {
		verifyErrMsg(IocErr#, ErrMsgs.datastore_idFieldNotFound(T_Entity12#)) {
			ds := (Datastore) scope.build(Datastore#, [T_Entity12#])
		}

		// check named _id properties are found
		ds := (Datastore) scope.build(Datastore#, [T_Entity13#])		
	}

	Void testIdTypeCheck() {
		ds := (Datastore) scope.build(Datastore#, [T_Entity13#])
		
		verifyErrMsg(ArgErr#, ErrMsgs.datastore_idDoesNotFit("2", T_Entity13#id)) {
			ob := ds["2"]
		}
		
		verifyErrMsg(ArgErr#, ErrMsgs.datastore_idDoesNotFit("3", T_Entity13#id)) {
			ds.deleteById("3")
		}
	}

	Void testEntityTypeCheck() {
		ds := (Datastore) scope.build(Datastore#, [T_Entity13#])

		verifyErrMsg(ArgErr#, ErrMsgs.datastore_entityWrongType(Str#, T_Entity13#)) {
			ds.delete("2")
		}

		verifyErrMsg(ArgErr#, ErrMsgs.datastore_entityWrongType(Str#, T_Entity13#)) {
			ds.update("2")
		}
	}
	
	Void testPropertyMustFit() {
		verifyErrMsg(MorphiaErr#, ErrMsgs.datastore_facetTypeDoesNotFitField(Int#, T_Entity15#inty)) {
			DatastoreImpl.verifyEntityType(T_Entity15#)
		}
	}

	Void testDuplicatePropertyNames() {
		verifyErrMsg(MorphiaErr#, ErrMsgs.datastore_duplicatePropertyName("_id", T_Entity17#_id, T_Entity17#anotherId)) {
			DatastoreImpl.verifyEntityType(T_Entity17#)
		}
	}

}

internal class T_Entity09 { }

@Entity
internal class T_Entity10 { @Property Int _id }

@Entity { name="Dude" } 
internal class T_Entity11 { @Property Int _id }

@Entity 
internal class T_Entity12 { @Property Int id }

@Entity 
internal class T_Entity13 { @Property { name="_id" } Int id }

@Entity
internal class T_Entity15 {
	@Property Int _id
	@Property { type=Int# }	Str	inty
	new make(|This|in) { in(this) }
}

@Entity
internal class T_Entity17 {
	@Property Int? _id
	@Property { name="_id" } Int? anotherId
}
