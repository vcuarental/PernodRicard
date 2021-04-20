/*********************************************************************************
 * Name:ASI_CRM_Payment_Invoice_AfterInsert
 * Description: Trigger After Insert for ASI_CRM_Payment_Invoice
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/11/2014       Laputa: Conrad          Created
 * 02/12/2014       Laputa: Conrad          Temporary comment out the routing table logic
*********************************************************************************/
trigger ASI_CRM_Payment_Invoice_AfterInsert on ASI_CRM_Payment_Invoice__c (After insert) {     
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice')){
        //ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_AssignApprover_RoutingTable());                   
    }
    
     if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Indirect_Rebate_Invoice_Read_Only') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Foc_Invoice_Read_Only') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_Cash_Invoice_Read_Only')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {            
            //new ASI_CRM_JP_InvoiceClone()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }     
}