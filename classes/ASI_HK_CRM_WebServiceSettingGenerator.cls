public with sharing class ASI_HK_CRM_WebServiceSettingGenerator {
	
	public static final String DEF_VALUE_NAME = 'Test Name';
	public static final String RT_ASI_HK_CRM = 'ASI_HK_CRM_Master';
	public static final String RT_SO = 'ASI_HK_CRM_Sales_Order';

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Web_Service_Setting__c'];
				RTMap = new Map<String, RecordType>();
				for (RecordType rt : RTList) {
					RTMap.put(rt.DeveloperName, rt);
				}
			}
			return RTMap;
		}
		set;
	}
	
	public static void initSOWSSetting() {
		ASI_HK_CRM_WebServiceSettingGenerator myGen = new ASI_HK_CRM_WebServiceSettingGenerator();
		ASI_HK_CRM_Web_Service_Setting__c soWSSetting = myGen.generateWSSetting('ASI_HK_CRM_SalesOrderSubmit', 'https://test.com', 'username', 'password', RT_SO);
		soWSSetting.ASI_HK_CRM_SO_Processing_Version__c = 'S1CRM';
		soWSSetting.ASI_HK_CRM_SO_Line_Item_Action_Type__c = '1';
		insert soWSSetting;
	}
	
	public static void initARWSSetiing() {
		ASI_HK_CRM_WebServiceSettingGenerator myGen = new ASI_HK_CRM_WebServiceSettingGenerator();
		ASI_HK_CRM_Web_Service_Setting__c arWSSetting = myGen.generateWSSetting('ASI_HK_CRM_ARCheck', 'https://test.com', 'username', 'password', RT_SO);
		insert arWSSetting;
	}

	public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
	
	public ASI_HK_CRM_Web_Service_Setting__c generateBasicWSSetting(String key, String baseUrl, String username, String password) {
		return new ASI_HK_CRM_Web_Service_Setting__c(
			ASI_HK_CRM_Key__c = key
			, ASI_HK_CRM_Base_URL__c = baseUrl
			, ASI_HK_CRM_Username__c = username
			, ASI_HK_CRM_Password__c = password
		);
	}

	public ASI_HK_CRM_Web_Service_Setting__c generateWSSetting(String key, String baseUrl, String username, String password, ID rtID) {
		ASI_HK_CRM_Web_Service_Setting__c result = generateBasicWSSetting(key, baseUrl, username, password);
		result.RecordTypeId = rtID;
		return result;
	}

	public ASI_HK_CRM_Web_Service_Setting__c generateWSSetting(String key, String baseUrl, String username, String password, String rtDevName) {
		return generateWSSetting(key, baseUrl, username, password, getRecordTypeByDevName(rtDevName).Id);
	}

}