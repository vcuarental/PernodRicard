/***************************************************************************************************************************
* Name:        ASI_KOR_BarStyling_Scheduler
* Description: Schduler for ASI_KOR_POSM_Order_Request
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2013-04-25       Thierry Barret          Created
* 2018-12-07       Alan Lau                Added method for creating a map from Custom Setting's fields
* 2018-12-19       Alan Lau                Added methods for getting a list of SObject field's value(String) and getting the month number by the month name
****************************************************************************************************************************/
public with sharing class ASI_KOR_CommonUtils {

	public final static List<String> MONTH_LIST = new List<String>{ //20181219 Alan Lau
			'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
	};
	
	public static String generateSeparatedStringWithQuote(List<String> strList, String delim, String quote) {
		String result = '';
		if (strList != null && strList.size() > 0) {
			result = String.join(strList, quote + delim + quote);
			result = quote + result + quote;
		}
		return result;
	}

	public static Map<String, String> getMapFromCustomSetting(Map<String, SObject> customSetting, String targetKeyField, String targetValueField) { //20181207 Alan Lau
		Map<String, String> mapOfTargetKeyToTargetValue = new Map<String, String>();

		for (String customSettingKey : customSetting.keySet()) {
			if (!isTargetKeyValueBlank(customSetting, customSettingKey, targetKeyField)) {
				mapOfTargetKeyToTargetValue.put((String) customSetting.get(customSettingKey).get(targetKeyField), (String) customSetting.get(customSettingKey).get(targetValueField));
			}
		}

		return mapOfTargetKeyToTargetValue;
	}

	public static List<String> getStringFieldList(List<SObject> sObjectList, String fieldName) { //20181219 Alan Lau
		List<String> stringList = new List<String>();

		for (SObject sObj : sObjectList) {
			String fieldValue = (String) sObj.get(fieldName);
			if (String.isNotBlank(fieldValue) && !stringList.contains(fieldValue)) {
				stringList.add(fieldValue);
			}
		}

		return stringList;
	}

	public static Integer getMonthNumber(String monthName) { //20181219 Alan Lau
		return MONTH_LIST.indexOf(monthName) + 1;
	}

	private static Boolean isTargetKeyValueBlank(Map<String, SObject> customSetting, String customSettingKey, String targetKeyField) { //20181207 Alan Lau
		if (String.isBlank((String) customSetting.get(customSettingKey).get(targetKeyField))) {
			return true;
		} else {
			return false;
		}
	}
}