trigger EUR_CRM_ContractTrackerTrigger on EUR_CRM_Contract_Tracker__c (after insert) {

    new EUR_CRM_ContractTrackerTriggerHandler().run();

}