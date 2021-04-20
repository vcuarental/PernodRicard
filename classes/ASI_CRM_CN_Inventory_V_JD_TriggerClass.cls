public without sharing class ASI_CRM_CN_Inventory_V_JD_TriggerClass {
    
	public static void routineBeforeInsert(list<ASI_CRM_Inventory_Visibility_Junc_Detail__c> trigger_new) {
        assignNumberFields(trigger_new);
    }
    
    public static void routineBeforeUpdate(list<ASI_CRM_Inventory_Visibility_Junc_Detail__c> trigger_new, map<id, ASI_CRM_Inventory_Visibility_Junc_Detail__c> trigger_oldMap) {
        assignNumberFields(trigger_new);
    }
    
    private static void assignNumberFields(list<ASI_CRM_Inventory_Visibility_Junc_Detail__c> trigger_new) {
        for (ASI_CRM_Inventory_Visibility_Junc_Detail__c oRecord : trigger_new) {
            oRecord.ASI_CRM_QTY__c = oRecord.ASI_CRM_Detail_QTY__c;
            
            if (oRecord.ASI_CRM_QTY__c == null) oRecord.ASI_CRM_QTY__c = 0;
        }
    }
    
}