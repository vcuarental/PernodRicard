/***************************************************************************************************************************
 * Name:        ASI_eForm_Donation_Request_AfterInsert
 * Description: Apex class for ASI_eForm_Donation_Request_AfterInsert
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-27       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

trigger ASI_eForm_Donation_Request_AfterInsert on ASI_eForm_Donation_Request__c (after insert) {
    if(Global_RecordTypeCache.getRt(Trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_eForm_KR')) {
        ASI_eForm_KR_DonationRequestTriggerClass.manualShareToSalesAdmin(Trigger.new, null);
    }
}