
** 'IoC Config' values as provided by Morphia. To change their value, override them in your AppModule. Example:
** 
** pre>
** @Contribute { serviceType=ApplicationDefaults# }
** static Void contributeAppDefaults(MappedConfig config) {
**     config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
** }
** <pre
const class MorphiaConfigIds {

	** Use to set the [Mongo Connection URL]`http://docs.mongodb.org/manual/reference/connection-string/`.
	** 
	** pre>
	** @Contribute { serviceType=ApplicationDefaults# }
	** static Void contributeAppDefaults(MappedConfig config) {
	**     config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
	** }
	** <pre
	static const Str mongoUrl	:= "afMorphia.mongoUrl"

}
