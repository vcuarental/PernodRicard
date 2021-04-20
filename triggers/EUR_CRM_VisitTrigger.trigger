trigger EUR_CRM_VisitTrigger on EUR_CRM_Visit__c (before insert, before update, after insert, after update, before
        delete) {

    new EUR_CRM_VisitTriggerHandler().run();

}