/**********************************************************************************
 * Name : ASI_KOR_SalesOrderRequestTransaction_AfterInsert
 * Created : DC @03/30/2016 11:21 AM
 * Revision History:
 * 1. 03/30/2016 - [DC 1.0] Created
 **********************************************************************************/

trigger ASI_KOR_SalesOrderRequestTransaction_AfterInsert on ASI_KOR_Sales_Order_Transaction__c (after insert) {

    // DC - 03/30/2016 - For SG CRM
    
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Wholesaler')) {
        
            /* will do the FOC calculation in the controller
            List<ASI_CRM_SG_TriggerAbstract> lstSgCrmClasses = new List<ASI_CRM_SG_TriggerAbstract>();
            if(ASI_CRM_SG_PopulateFoc.runOnce()){
                lstSgCrmClasses.add(new ASI_CRM_SG_PopulateFoc());
    
                for(ASI_CRM_SG_TriggerAbstract triggerAbstract : lstSgCrmClasses) {
                    triggerAbstract.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
                }
            }
            */
        }

        // For sales order item validation added by jack
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_SalesOrder_Item')) {
            ASI_CTY_CN_WS_SORItem_TriggerClass.routineAfterUpsert(Trigger.newMap);
        }
}