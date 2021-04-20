public class EUR_CRM_OP_ActionTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void beforeInsert() {
        new EUR_CRM_OP_ActionValidationService().validate(Trigger.new);
    }

    override protected void beforeUpdate() {
        new EUR_CRM_OP_ActionValidationService().validate(Trigger.new);
    }

    override protected void beforeDelete() {
        new EUR_CRM_OP_ActionValidationService().validate(Trigger.old);
    }

}