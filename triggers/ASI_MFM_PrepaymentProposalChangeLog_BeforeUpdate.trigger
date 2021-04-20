trigger ASI_MFM_PrepaymentProposalChangeLog_BeforeUpdate on ASI_MFM_Prepayment_Proposal_Change_Log__c (Before Update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR_')){
        ASI_MFM_KR_PrepayChangeLog_TriggerClass.beforeUpdateMethod(trigger.new, trigger.oldMap);
    }
}