public with sharing class ASI_CRM_KR_ListedMenuPrice_TriggerClass {
    
	public static void routineBeforeInsert(list<ASI_CRM_KR_Listed_Menu_Price__c> trigger_new) {
        for(ASI_CRM_KR_Listed_Menu_Price__c lmp:trigger_new){
            lmp.ASI_CRM_KR_Unique_ID__c=null;
            
        }
    }
    
}