/*********************************************************************************
 * Name: ASI_CRM_SKUPriceCost_AfterInsert
 * Description: trigger for SKU Price Cost record after insert 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/02/2017       Laputa:Hugo             Created
 *              
*/
trigger ASI_CRM_SKUPriceCost_AfterInsert on ASI_CRM_MY_SKUPriceCost__c (after insert) {
	
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG')) {
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
        	new ASI_CRM_SG_AutoCreateSKUPrice()
        };
            
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
       		triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
        }
    }
    
}