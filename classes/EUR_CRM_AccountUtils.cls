public class EUR_CRM_AccountUtils {
	
	//id -> recordtype map
	public static Map<Id, Recordtype> recordtypeMap = new Map<Id, Recordtype>([Select Id, DeveloperName From Recordtype 
			Where SobjectType = 'EUR_CRM_Account__c' LIMIT 5000]);
	
	public static Schema.RecordTypeInfo EUR_CRM_GENERAL_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EUR CRM General');
}