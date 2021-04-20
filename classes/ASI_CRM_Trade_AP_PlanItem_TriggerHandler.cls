/*********************************************************************************
 * Name: ASI_CRM_Trade_AP_PlanItem_TriggerHandler
 * Description: Trigger Handler for Object Trade A&P Plan Item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/01/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_Trade_AP_PlanItem_TriggerHandler {
    
    private final static String DRAFT_STATUS = 'Draft';
    private final static String SUBMITTED_STATUS = 'Submitted';
    private final static String APPROVED_STATUS = 'Approved';
    
    private final static Id PLAN_ITEM_READ_ONLY_RECORD_TYPE = Global_RecordTypeCache.getRtId('ASI_CRM_Trade_A_P_Plan_Item__c' + 'ASI_CRM_VN_Promotion_Plan_Item_Read_Only');
    
    //Error Message
    private final static String UPSERT_ERROR_MESSAGE = 'Cannot create/edit Promotion Plan Item during approval process!';
    private final static String DELETE_ERROR_MESSAGE = 'Cannot delete approved/submitted Promotion Plan Item!';
    
    public ASI_CRM_Trade_AP_PlanItem_TriggerHandler() {
    }
    
    public void beforeInsertTrigger(List<sObject> newList) {
        List<ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemList = (List<ASI_CRM_Trade_A_P_Plan_Item__c>) newList;
        
        validateBeforeInsert(tradeAPPlanItemList);
    }
    
    public void beforeUpdateTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemList = (List<ASI_CRM_Trade_A_P_Plan_Item__c>) newList;
    	Map<Id, ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemMap = (Map<Id, ASI_CRM_Trade_A_P_Plan_Item__c>) oldMap;
        
    }
    
    public void beforeDeleteTrigger(List<sObject> oldList) {
        List<ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemList = (List<ASI_CRM_Trade_A_P_Plan_Item__c>) oldList;
        
        validateBeforeDelete(tradeAPPlanItemList);
    }
    
    //Validation Handler
    private void validateBeforeInsert(List<ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemList) {
        Set<Id> tradeAPPlanIdSet = new Set<Id>();
        for(ASI_CRM_Trade_A_P_Plan_Item__c tradeAPPlanItem : tradeAPPlanItemList) {
        	tradeAPPlanIdSet.add(tradeAPPlanItem.ASI_CRM_Trade_A_P_Plan__c);
        }
        
        Map<Id, ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanMap = new Map<Id, ASI_CRM_Trade_A_P_Plan__c>(retrieveTradeAPPlanList(tradeAPPlanIdSet));
        
        for(ASI_CRM_Trade_A_P_Plan_Item__c tradeAPPlanItem : tradeAPPlanItemList) {
            ASI_CRM_Trade_A_P_Plan__c tradeAPPlan = tradeAPPlanMap.get(tradeAPPlanItem.ASI_CRM_Trade_A_P_Plan__c);
            if(tradeAPPlan.ASI_CRM_Status__c != DRAFT_STATUS &&
               tradeAPPlanItem.RecordTypeId != PLAN_ITEM_READ_ONLY_RECORD_TYPE) {
            	tradeAPPlanItem.addError(UPSERT_ERROR_MESSAGE);
            }
        }
    }
    
    private void validateBeforeDelete(List<ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemList) {
        Set<Id> tradeAPPlanIdSet = new Set<Id>();
        for(ASI_CRM_Trade_A_P_Plan_Item__c tradeAPPlanItem : tradeAPPlanItemList) {
        	tradeAPPlanIdSet.add(tradeAPPlanItem.ASI_CRM_Trade_A_P_Plan__c);
        }
        
        Map<Id, ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanMap = new Map<Id, ASI_CRM_Trade_A_P_Plan__c>(retrieveTradeAPPlanList(tradeAPPlanIdSet));
        
        for(ASI_CRM_Trade_A_P_Plan_Item__c tradeAPPlanItem : tradeAPPlanItemList) {
            ASI_CRM_Trade_A_P_Plan__c tradeAPPlan = tradeAPPlanMap.get(tradeAPPlanItem.ASI_CRM_Trade_A_P_Plan__c);
            if(tradeAPPlan.ASI_CRM_Status__c == APPROVED_STATUS || 
               tradeAPPlan.ASI_CRM_Status__c == SUBMITTED_STATUS) {
            	tradeAPPlanItem.addError(DELETE_ERROR_MESSAGE);
            }
        }
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_CRM_Trade_A_P_Plan__c> retrieveTradeAPPlanList(Set<Id> tradeAPPlanIdSet) {
        List<ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanList = [SELECT Id, ASI_CRM_Status__c
                                                           FROM ASI_CRM_Trade_A_P_Plan__c
                                                           WHERE Id in :tradeAPPlanIdSet];
        
        return tradeAPPlanList;
    }
}