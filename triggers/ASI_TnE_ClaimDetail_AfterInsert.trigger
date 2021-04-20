/*********************************************************************************
 * Name:ASI_TnE_ClaimDetail_AfterInsert 
 * Description: After Insert Trigger for TnE Claim Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 6/3/2015         Laputa: Hank            Updated
*********************************************************************************/
trigger ASI_TnE_ClaimDetail_AfterInsert on ASI_TnE_ClaimDetail__c (after insert) {  
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_VN')) {    
        ASI_TnE_ClaimDetailTriggerClass.routineAfterInsert(trigger.new, null);
    }
    List<ASI_TnE_TriggerAbstract> ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_SG_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_KH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_ID_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_PH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_MY_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TW_Claim_Detail')){
        ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract> { 
            new ASI_TnE_ClaimsDetailUpdateHeader()
        };                    
    } 
    
    if(/*Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail') ||*/
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_SG_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_KH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_PH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_MY_Claim_Detail')){
        ASI_TnE_triggerClasses.add(new ASI_TnE_ClaimsDetailUpdatePO());                
    } 
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail')){
        ASI_TnE_triggerClasses.add(new ASI_TnE_ClaimsDetailUpdatePlan());
    }
    
    //Added by Laputa Hugo Cheung for G&H Request    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TW_Claim_Detail')) {
        ASI_TnE_triggerClasses.add(new ASI_TnE_GnH_TW_UpdateGnHAmount());
    }
    
    for (ASI_TnE_TriggerAbstract triggerClass : ASI_TnE_triggerClasses){
        triggerClass.executeTriggerAction(ASI_TnE_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }        
}