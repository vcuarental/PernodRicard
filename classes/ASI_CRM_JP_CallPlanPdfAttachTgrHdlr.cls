/*********************************************************************************
 * Name:ASI_CRM_JP_CallPlanPdfAttachTgrHdlr
 * Description: Call Plan Trigger Handler for Attaching Pdf
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 1/12/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_CallPlanPdfAttachTgrHdlr extends ASI_CRM_JP_TriggerAbstract {
    

    public ASI_CRM_JP_CallPlanPdfAttachTgrHdlr() {
        super('ASI_CRM_JP_CallPlanPdfAttachTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Call_Plan__c> planList = (List<ASI_CRM_Call_Plan__c>)sObjList;
        List<Id> planIdList = new List<Id>();
        
        if (oldMap == null) {
        }
        else {
            Map<ID, ASI_CRM_Call_Plan__c> oldPlanMap = (Map<ID, ASI_CRM_Call_Plan__c>) oldMap;
            for (ASI_CRM_Call_Plan__c plan: planList) {
                if ((plan.ASI_CRM_Approved__c != oldPlanMap .get(plan.Id).ASI_CRM_Approved__c)  && plan.ASI_CRM_Approved__c == true){
                    planIdList.add(plan.Id);
                }
            }
        }
        ASI_CRM_JP_CallPlanPdfAttachController.addPDFAttach(userInfo.getSessionId(), planIdList);
    }
}