
** `IocConfig` values as provided by Morphia. To change their value, override them in your AppModule. Example:
** 
** pre>
** @Contribute { serviceType=ApplicationDefaults# }
** static Void contributeAppDefaults(MappedConfig config) {
**     config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
** }
** <pre
const class MorphiaConfigIds {

	** The main document converter to use (instance of `Converter`).
	** 
	** Defaults to 'DocumentConverter(false)' which *does not* store keys with 'null' values. 
	** If you prefer a key with a 'null' value to be stored, contribute a new `DocumentConverter`:
	** 
	** pre>
	** @Contribute { serviceType=ApplicationDefaults# }
	** static Void contributeAppDefaults(MappedConfig config) {
	**     config[MorphiaConfigIds.documentConverter] = config.createProxy(Converter#, DocumentConverter#, [true])
	** }
	** <pre 
	** 
	** @see
	**  - `DocumentConverter` 
	**  - [Storing null vs not storing the key at all in MongoDB]`http://stackoverflow.com/questions/12403240/storing-null-vs-not-storing-the-key-at-all-in-mongodb`   
	static const Str documentConverter	:= "afMorphia.documentConverter"

	** Use to set the [Mongo Connection URL]`http://docs.mongodb.org/manual/reference/connection-string/`.
	** 
	** pre>
	** @Contribute { serviceType=ApplicationDefaults# }
	** static Void contributeAppDefaults(MappedConfig config) {
	**     config[MorphiaConfigIds.mongoUrl] = `mongodb://localhost:27017/exampledb`
	** }
	** <pre
	static const Str mongoUrl			:= "afMorphia.mongoUrl"

}
