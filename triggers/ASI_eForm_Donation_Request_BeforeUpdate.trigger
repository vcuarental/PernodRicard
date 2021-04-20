trigger ASI_eForm_Donation_Request_BeforeUpdate on ASI_eForm_Donation_Request__c (before update) {
    if(Global_RecordTypeCache.getRt(Trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_eForm_KR')) {
        ASI_eForm_KR_DonationRequestTriggerClass.manualShareToSalesAdmin(Trigger.new, Trigger.oldMap);
    }
}