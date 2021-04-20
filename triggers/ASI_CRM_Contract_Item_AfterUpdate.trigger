/*********************************************************************************
 * Name:ASI_CRM_Contract_Item_AfterUpdate
 * Description: After Update Contract Item Trigger for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/12/2014       Laputa: Hank          Created
*********************************************************************************/
trigger ASI_CRM_Contract_Item_AfterUpdate on ASI_CRM_Purchase_Contract_Line_Item__c (after update) {     
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Rebate_Contract_Line_Item') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Contract_Line_Item') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Contract_Line_Item')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {            
            new ASI_CRM_JP_ContractItemUpdateApprover()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}