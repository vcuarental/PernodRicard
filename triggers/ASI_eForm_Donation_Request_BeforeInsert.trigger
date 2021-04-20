trigger ASI_eForm_Donation_Request_BeforeInsert on ASI_eForm_Donation_Request__c (before insert) {
    if(Global_RecordTypeCache.getRt(Trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_eForm_KR')) {
        ASI_eForm_KR_DonationRequestTriggerClass.routineBeforeUpsert(Trigger.new, null);
    }
}