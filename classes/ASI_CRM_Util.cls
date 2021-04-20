public class ASI_CRM_Util {

	public static String toJsonString(Object obj) {
		return System.JSON.serialize(obj);
	}

	public static List<String> getPropertyList(List<SObject> objectList, String fieldName) {
		final List<String> propertyList = new List<String>();

		if(objectList != null && !objectList.isEmpty()) {
			for (SObject so : objectList) {
				if(String.isNotBlank(fieldName)) {
					propertyList.add(String.valueOf(so.get(fieldName)));
				}
			}
		}

		return propertyList;
	}

	public static Map<String, SObject> getFieldObjectMap(List<SObject> objectList, String fieldName) {
		final Map<String, SObject> fieldObjectMap = new Map<String, SObject>();

		System.debug(objectList);
		for (SObject so : objectList) {
			fieldObjectMap.put(String.valueOf(so.get(fieldName)), so);
		}

		return fieldObjectMap;

	}

}