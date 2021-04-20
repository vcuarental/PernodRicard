/*********************************************************************************
 * Name:ASI_TnE_ClaimsChangeManagerAccess
 * Description: Change Manager Access for TnE Claims Header
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/3/2015         Laputa: Hank            Created
*********************************************************************************/

public without sharing class ASI_TnE_ClaimsChangeManagerAccess extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsChangeManagerAccess() {
        super('ASI_TnE_ClaimsChangeManagerAccess');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_TnE_ClaimHeader__c> claimList = (List<ASI_TnE_ClaimHeader__c>)sObjList;
        Map<String, String> accessLevel = new Map<String, String>();
        accessLevel.put('ASI_TnE_Payee_Employee__c', 'Edit');
        accessLevel.put('ASI_TnE_Checker__c', 'Edit');
        ASI_TnE_GenericTriggerClass.assignRecordPermission(claimList, 'ASI_TnE_ClaimHeader__Share', 
                                                           'ASI_TnE_Claims_Change_Manager_Access__c', 
                                                           new String[] {'ASI_TnE_Payee_Employee__c', 'ASI_TnE_Sys_Approver_1__c', 'ASI_TnE_Sys_Approver_2__c',
                                                                         'ASI_TnE_Sys_Approver_3__c', 'ASI_TnE_Sys_Approver_4__c', 
                                                                         'ASI_TnE_Sys_Approver_5__c', 'ASI_TnE_Sys_Approver_6__c',
                                                                         'ASI_TnE_Sys_Approver_7__c', 'ASI_TnE_Checker__c'}, 
                                                           (oldMap == null?null:(Map<Id, ASI_TnE_ClaimHeader__c>)oldMap), accessLevel);  
    }
    
}