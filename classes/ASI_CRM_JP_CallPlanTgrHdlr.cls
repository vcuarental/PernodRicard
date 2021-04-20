/*********************************************************************************
 * Name:ASI_CRM_JP_CallPlanTgrHdlr
 * Description: Call Plan Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_CallPlanTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_CallPlanTgrHdlr() {
        super('ASI_CRM_JP_CallPlanTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Call_Plan__c> planList = (List<ASI_CRM_Call_Plan__c>)sObjList;
        Set<Id> ownerIdSet = new Set<Id>();
        
        if (oldMap == null) {
            for (ASI_CRM_Call_Plan__c plan : planList) {
                ownerIdSet.add(plan.ownerId);
            }
        }
        else {
            Map<ID, ASI_CRM_Call_Plan__c> oldPlanMap = (Map<ID, ASI_CRM_Call_Plan__c>) oldMap;
            for (ASI_CRM_Call_Plan__c plan: planList) {
                if (plan.ownerId != null && (plan.ownerId != oldPlanMap.get(plan.Id).ownerId)) {
                    ownerIdSet.add(plan.ownerId);
                }
            }
        }
        
        Map<Id, User> ownerMap = new Map<Id, User>([Select Id, ASI_KOR_User_Branch_Code__c From User Where Id In :ownerIdSet]);
       
        if (oldMap == null) {
            for (ASI_CRM_Call_Plan__c plan : planList) {
                plan.ASI_CRM_Sales_Group__c = ownerMap.get(plan.ownerId).ASI_KOR_User_Branch_Code__c;
            }
        }
        else {
            Map<ID, ASI_CRM_Call_Plan__c> oldPlanMap = (Map<ID, ASI_CRM_Call_Plan__c>) oldMap;
            for (ASI_CRM_Call_Plan__c plan: planList) {
                if (plan.ownerId != null && (plan.ownerId != oldPlanMap.get(plan.Id).ownerId)) {
                    plan.ASI_CRM_Sales_Group__c = ownerMap.get(plan.ownerId).ASI_KOR_User_Branch_Code__c;
                }
            }
        }      
    }
}