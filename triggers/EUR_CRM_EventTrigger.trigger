trigger EUR_CRM_EventTrigger on Event (after update) {

    new EUR_CRM_EventTriggerHandler().run();
    
}