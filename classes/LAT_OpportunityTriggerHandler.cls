public with sharing class LAT_OpportunityTriggerHandler {
	public static List<LAT_Opportunity__c> triggerNew{get;set;}
	public static List<LAT_Opportunity__c> triggerOld{get;set;}
	public static Map<Id, LAT_Opportunity__c> mapNew{get;set;}
	public static Map<Id, LAT_Opportunity__c> mapOld{get;set;}
	

	public static void init(List<LAT_Opportunity__c> tNew,List<LAT_Opportunity__c> tOld, Map<Id, LAT_Opportunity__c> mNew, Map<Id, LAT_Opportunity__c> mOld) {
		triggerNew = tNew;
		triggerOld = tOld;
		mapNew = mNew;
		mapOld = mOld;
	}
}