trigger EUR_CRM_OP_ActionTrigger on EUR_CRM_OP_Action__c (before insert, before update, before delete) {

    new EUR_CRM_OP_ActionTriggerHandler().run();

}