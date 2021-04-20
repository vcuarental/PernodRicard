public with sharing class ASI_MFM_TW_ResetPlanApprover_TgrHdlr extends ASI_HK_CRM_TriggerAbstract {
    
    public ASI_MFM_TW_ResetPlanApprover_TgrHdlr() {
        super('ASI_MFM_TW_ResetPlanApprover_TgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        for(sObject obj: sObjList){
            ASI_MFM_Plan__c newPlan = (ASI_MFM_Plan__c)obj;
            
            ASI_MFM_Plan__c oldPlan = null;
            
            if (oldMap != null && oldMap.get(newPlan.id) != null){
                oldPlan = (ASI_MFM_Plan__c)oldMap.get(newPlan.id);
            }
            
            System.debug('newPlan:' + newPlan);
            System.debug('oldPlan:' + oldPlan);
            
            
            if(newPlan.ASI_MFM_Status__c == 'Submitted' && oldPlan != null && oldPlan.ASI_MFM_Status__c == 'Draft'){
                newPlan.ASI_MFM_Sys_Approver_Email_Address__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address1__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address2__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address3__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address4__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address5__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address6__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address7__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address8__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address9__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address10__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address11__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address12__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address13__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address14__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address15__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address16__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address17__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address18__c = null;
                newPlan.ASI_MFM_Sys_Approver_Email_Address19__c = null;
            }
        }
    }
}