/*********************************************************************************
 * Name:ASI_CRM_Call_Detail_BeforeUpdate
 * Description: Before Update Trigger for ASI JP Call Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 24/11/2014       Laputa: Hank          Created
*********************************************************************************/
trigger ASI_CRM_Call_Detail_BeforeUpdate on ASI_CRM_Call_Detail__c (before update) {     
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Plan_Detail') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Result_Detail') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Result_Detail_Locked') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Plan_Detail_Repeat') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Result_Detail_Repeat') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Result_Detail_Invoice') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Plan_Detail_Repeat_Settings')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> { 
            new ASI_CRM_JP_CallDetailCalcNumOfAttendees(),         
            new ASI_CRM_JP_CallDetailCreateTnEPlan(),
            new ASI_CRM_JP_CallDetailUpdatePayTo()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }        
}