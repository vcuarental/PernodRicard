public class ASI_CRM_QueryUtil {

	public static String getSelectAllFieldsQueryString(SObjectType objectType, String filterCriteria) {

		if (String.isBlank(filterCriteria)) return null;

		final String objectName = objectType.getDescribe().getName();
		final String fields = getSObjectFieldsForQuery(objectType);
		final String query = 'SELECT ' + fields + ' FROM ' + objectName + ' ' + filterCriteria;

		return query;
	}

	public static List<String> getSObjectFieldList(SObjectType objectType) {
		final Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
		final List<String> selectFields = new List<String>();

		for (Schema.SObjectField objectField : fieldMap.values()) {
			if (!objectField.getDescribe().isCreateable()) continue;

			selectFields.add(objectField.getDescribe().getName());
		}

		return selectFields;
	}

	public static String getSObjectFieldsForQuery(SObjectType objectType) {
		return String.join(getSObjectFieldList(objectType), ',');
	}

	public static String getListStringForQuery(List<String> values) {
		return '\'' + String.join(values, '\', \'') + '\'';
		//		return String.join(values, ',');
	}

	public static String getListStringForQuery(List<Id> ids) {
		return '\'' + String.join(ids, '\', \'') + '\'';
	}

	public static String getListStringForQuery(Set<String> values) {
		return getListStringForQuery(new List<String>(values));
	}

	public static String getListStringForQuery(Set<Id> values) {
		return getListStringForQuery(new List<Id>(values));
	}

	public static String encloseWithQuotes(String value) {
		if (value == null || value == '') return value;

		return '\'' + value + '\'';
	}

	public static String getDateForQuery(DateTime dateTimeInstance) {
		if (dateTimeInstance == null) return null;

		return dateTimeInstance.format('yyyy-MM-dd');
	}

	public static SObjectType getSObjectTypeByName(String sObjectName) {
		return Schema.getGlobalDescribe().get(sObjectName);
	}

}