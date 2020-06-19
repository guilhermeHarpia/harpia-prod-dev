public interface ICustomFieldConfigurator {
	void configure(Schema.SObjectField customIdField, List<SObject> recordList, List<Schema.SObjectField> fieldList);
}