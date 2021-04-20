/*********************************************************************************
 * Name:ASI_GnH_RequestRecipient_BeforeInsert 
 * Description: Before Insert Trigger for ASI_GnH_Request_Recipient__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 29/5/2017         Laputa: Kevin Choi      Created
*********************************************************************************/

trigger ASI_GnH_RequestRecipient_BeforeInsert on ASI_GnH_Request_Recipient__c (before insert) {
    
     List<ASI_TnE_TriggerAbstract> ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_GnH_KR_Request_Recipient')){
        ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract>{ 
            new ASI_GnH_KR_InsertRecipientMaster()
        };                    
    }
    
    for (ASI_TnE_TriggerAbstract triggerClass : ASI_TnE_triggerClasses){
        triggerClass.executeTriggerAction(ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
        
    }            

}