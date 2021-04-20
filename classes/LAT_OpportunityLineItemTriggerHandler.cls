public with sharing class LAT_OpportunityLineItemTriggerHandler {
	public static List<LAT_OpportunityLineItem__c> triggerNew{get;set;}
	public static List<LAT_OpportunityLineItem__c> triggerOld{get;set;}
	public static Map<Id, LAT_OpportunityLineItem__c> mapNew{get;set;}
	public static Map<Id, LAT_OpportunityLineItem__c> mapOld{get;set;}
	

	public static void init(List<LAT_OpportunityLineItem__c> tNew,List<LAT_OpportunityLineItem__c> tOld, Map<Id, LAT_OpportunityLineItem__c> mNew, Map<Id, LAT_OpportunityLineItem__c> mOld) {
		triggerNew = tNew;
		triggerOld = tOld;
		mapNew = mNew;
		mapOld = mOld;
	}
}