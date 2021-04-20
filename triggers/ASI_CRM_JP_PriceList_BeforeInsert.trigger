/*********************************************************************************
 * Name: ASI_CRM_JP_PriceList_BeforeInsert
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/06/2017       Hugo Cheung             Created          
*/
trigger ASI_CRM_JP_PriceList_BeforeInsert on ASI_CRM_Price_List__c (before insert) {
	List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_PriceListAssignApprover());
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    } 
}