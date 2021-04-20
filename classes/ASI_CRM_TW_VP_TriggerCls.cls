public with sharing class ASI_CRM_TW_VP_TriggerCls{
    public static void routineBeforeDelete(list<ASI_HK_CRM_Visitation_Plan__c> trigger_old) {
        Set<Id> setVPId = new Set<Id>();
        Set<Id> setVPwithActualVisits = new Set<Id>();
        
        for(ASI_HK_CRM_Visitation_Plan__c vp : trigger_old){
            setVPId.add(vp.id);
        }
        
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : [SELECT id, ASI_HK_CRM_Visitation_Plan__c 
                                                        FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
                                                        WHERE ASI_HK_CRM_Visitation_Plan__c IN: setVPId AND
                                                        (ASI_TH_CRM_Visit_Date_Time_From__c != null OR ASI_TH_CRM_Visit_Date_Time_To__c != null) AND
                                                        (RecordTypeId =: Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Visitation_Plan_Detail') OR RecordTypeId =: Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Merchandiser_Visitation_Plan_Detail'))]){
            setVPwithActualVisits.add(vpd.ASI_HK_CRM_Visitation_Plan__c);
        }
        
        
        for(ASI_HK_CRM_Visitation_Plan__c vp : trigger_old){
            if(setVPwithActualVisits.contains(vp.id))
                vp.addError('Visitation Plan with actual visits cannot be deleted.');
        }
    }
}