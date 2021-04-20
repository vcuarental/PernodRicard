/***************************************************************************************************************************
 * Name: ASI_HK_CRM_SalesOrder_AfterUndelete
 * Description: 
 * Test Class: ASI_HK_CRM_SalesOrderTriggerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-09-05       Wilken Lee              [WL 1.0] Add record type checking for HK SO data
****************************************************************************************************************************/
trigger ASI_HK_CRM_SalesOrder_AfterUndelete on ASI_HK_CRM_Sales_Order__c (after undelete) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeID).DeveloperName.contains('HK_CRM')){    //[WL 1.0]
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_SalesOrderValidator()
        };
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_UNDELETE, trigger.new, trigger.newMap, null);
        }
    }//[WL 1.0]
}