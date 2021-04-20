/*********************************************************************************
 * Name:ASI_CRM_Purchase_Contract_AfterInsert
 * Description: Trigger After Insert for ASI_CRM_Purchase_Contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/11/2014       Laputa: Conrad          Created
 * 02/12/2014       Laputa: Conrad          Temporary Comment Routing table
 * 8/12/2014        Laputa: Hank            Add custom clone functions
*********************************************************************************/
trigger ASI_CRM_Purchase_Contract_AfterInsert on ASI_CRM_Purchase_Contract__c (After insert) {     
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Contract')){
        //ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_AssignApprover_RoutingTable());                   
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Rebate_Contract') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Contract') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Contract') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Rebate_Contract_Read_Only') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Contract_Read_Only') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Contract_Read_Only')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> { 
            new ASI_CRM_JP_ContractClone()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }     
}