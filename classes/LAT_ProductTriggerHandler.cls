public with sharing class LAT_ProductTriggerHandler {
	public static List<LAT_Product__c> triggerNew{get;set;}
	public static List<LAT_Product__c> triggerOld{get;set;}
	public static Map<Id, LAT_Product__c> mapNew{get;set;}
	public static Map<Id, LAT_Product__c> mapOld{get;set;}
	

	public static void init(List<LAT_Product__c> tNew,List<LAT_Product__c> tOld, Map<Id, LAT_Product__c> mNew, Map<Id, LAT_Product__c> mOld) {
		triggerNew = tNew;
		triggerOld = tOld;
		mapNew = mNew;
		mapOld = mOld;
	}

}