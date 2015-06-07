
** IoC Config values as provided by Morphia. To change their value, override them in your AppModule. Example:
** 
** pre>
** syntax: fantom
** 
** @Contribute { serviceType=ApplicationDefaults# }
** static Void contributeAppDefaults(Configuration config) {
**     config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
** }
** <pre
const mixin MorphiaConfigIds {

	** Use to set the [Mongo Connection URL]`http://docs.mongodb.org/manual/reference/connection-string/`.
	** 
	** pre>
	** syntax: fantom
	** 
	** @Contribute { serviceType=ApplicationDefaults# }
	** static Void contributeAppDefaults(Configuration config) {
	**     config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
	** }
	** <pre
	static const Str mongoUrl	:= "afMorphia.mongoUrl"

	** The name of the collection used by `IntSequences` to store last ID information.
	static const Str intSequencesCollectionName	:= "afMorphia.intSequencesCollectionName"

}
