/**
 * Created by larsz on 9/30/2020.
 */

public without sharing class EUR_CRM_RecoverySyncWrapper {
    public static void insertEventsWithoutSharing(List<Event> eventsToInsert) {
        insert eventsToInsert;
    }

    public static void insertContractPaymentPlansWithoutSharing(List<EUR_CRM_Contract_Payment_Plan__c> newContractPaymentPlans) {
        insert newContractPaymentPlans;
    }
}