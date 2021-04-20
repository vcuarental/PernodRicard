/***************************************************************************************************************************
 * Name: ASI_HK_CRM_SalesOrder_AfterUpdate
 * Description: 
 * Test Class: ASI_HK_CRM_SalesOrderTriggerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-09-05       Wilken Lee              [WL 1.0] Add record type checking for HK SO data
****************************************************************************************************************************/
trigger ASI_HK_CRM_SalesOrder_AfterUpdate on ASI_HK_CRM_Sales_Order__c (after update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeID).DeveloperName.contains('HK_CRM')){    //[WL 1.0]
        system.debug('ASI_HK_CRM_SalesOrder_AfterUpdate for HK Record Type');
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_SalesOrderRequestSubmit(), 
            new ASI_HK_CRM_SalesOrderNextApprover()
        };
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }//[WL 1.0]
    if(trigger.new[0].recordTypeId != null &&  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MY_CRM')){
    	ASI_MY_CRM_SalesOrder_Handler.routineAfterUpdate(Trigger.New, Trigger.NewMap, Trigger.Old, Trigger.OldMap);
    }
}