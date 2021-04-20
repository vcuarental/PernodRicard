public with sharing class ASI_CRM_TW_VPD_TriggerCls{
    public static void routineBeforeDelete(list<ASI_HK_CRM_Visitation_Plan_Detail__c> trigger_old) {
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : trigger_old){
            if(vpd.ASI_HK_CRM_Visit_Date__c < date.today()){
                vpd.addError('VPD before today cannot be deleted.');
            }
            else if(vpd.ASI_TH_CRM_Visit_Date_Time_From__c != NULL || vpd.ASI_TH_CRM_Visit_Date_Time_To__c != NULL){
                vpd.addError('VPD with actual visit cannot be deleted.');
            }
        }
    }
}