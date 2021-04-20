public class EUR_CRM_OP_TemplateHandler extends EUR_CRM_TriggerHandler {

    override protected void beforeUpdate() {
        new EUR_CRM_OP_TemplateValidationService().validate((Map<Id, EUR_CRM_OP_Template__c>)Trigger.newMap);
    }

}