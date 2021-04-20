public with sharing class LAT_CaseTriggerHandler {

	public static List<LAT_Case__c> triggerNew{get;set;}
	public static List<LAT_Case__c> triggerOld{get;set;}
	public static Map<Id, LAT_Case__c> mapNew{get;set;}
	public static Map<Id, LAT_Case__c> mapOld{get;set;}
	

	public static void init(List<LAT_Case__c> tNew,List<LAT_Case__c> tOld, Map<Id, LAT_Case__c> mNew, Map<Id, LAT_Case__c> mOld) {
		triggerNew = tNew;
		triggerOld = tOld;
		mapNew = mNew;
		mapOld = mOld;
	}


}