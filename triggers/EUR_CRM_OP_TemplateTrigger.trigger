trigger EUR_CRM_OP_TemplateTrigger on EUR_CRM_OP_Template__c (before update) {

    new EUR_CRM_OP_TemplateHandler().run();

}