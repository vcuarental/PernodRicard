public class EUR_CRM_AccGrpUsrTrgrHndlrWithoutSharing extends EUR_CRM_TriggerHandler {

    public static final String REMOVE = EUR_CRM_AccountGroupUserService.REMOVE;
    public static final String ADD = EUR_CRM_AccountGroupUserService.ADD;

    EUR_CRM_AccountGroupUserService service = new EUR_CRM_AccountGroupUserService();


    override protected void beforeDelete() {
        service.populateAccounts(Trigger.old, REMOVE);
    }

    override protected void afterUndelete() {
        service.populateAccounts(Trigger.new, ADD);
    }

    override protected void afterInsert() {
        service.populateAccounts(Trigger.new, ADD);
    }
}