/*********************************************************************************
 * Name: ASI_CRM_JP_CustomerProductPrice_BeforeInsert
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 02/03/2017       Hugo Cheung             Created          
*/
trigger ASI_CRM_JP_CustomerProductPrice_BeforeInsert on ASI_CRM_JP_Customer_Product_Price__c (before insert) {
     List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
     if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {
            new ASI_CRM_JP_AssignPriceCustomerGroup(),
            //new ASI_CRM_JP_AssignCustomProductPriceName(),
            new ASI_CRM_JP_ItemBasePriceAssignApprover()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    } 
}