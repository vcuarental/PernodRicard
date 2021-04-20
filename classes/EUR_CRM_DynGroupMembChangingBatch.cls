public without sharing class EUR_CRM_DynGroupMembChangingBatch extends EUR_CRM_CacheBatch {

    public static final Integer GROUP_MEMBERS_SCOPE_SIZE = 200;
    public static final Integer GROUPS_SCOPE_SIZE = 10; //Used in 'for' loop, can not to be a lot

    private EUR_CRM_DynamicGroupService.GroupType groupType;
    private List<SObject> groupMembers;
    private EUR_CRM_DynamicGroupService.GroupMembChangingProcess process;

    protected override String getBathId() {
        return EUR_CRM_CacheBatchService.DYN_GROUP_MEMB_CHANGING_BATCH_ID;
    }

    protected override Integer getIterableCashesQuantity() {
        return GROUP_MEMBERS_SCOPE_SIZE;
    }

    protected override void scheduleBatch() {
        EUR_CRM_BatchService.scheduleBatch(this, GROUP_MEMBERS_SCOPE_SIZE, 'EUR_CRM_DynGroupMembChangingBatch' + String.valueOf(groupType));
    }

    protected override void executeNextBatch() {
        Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(groupType), GROUP_MEMBERS_SCOPE_SIZE);
    }

    public EUR_CRM_DynGroupMembChangingBatch(EUR_CRM_DynamicGroupService.GroupType groupType){
        this.groupType = groupType;
        process = EUR_CRM_DynamicGroupService.GroupMembChangingProcess.MEMBERS_SELECTING;
    }

    public EUR_CRM_DynGroupMembChangingBatch(List<EUR_CRM_Cache__c> iterableCashes, List<SObject> groupMembers, EUR_CRM_DynamicGroupService.GroupMembChangingProcess process){
        super(iterableCashes);
        this.groupMembers = groupMembers;
        this.groupType = EUR_CRM_DynamicGroupService.getGroupType(groupMembers[0]);
        this.process = process;
    }

    protected override Database.QueryLocator getQueryForStart(Set<Id> iterableSObjectIds) {
        String query;
        if(process == EUR_CRM_DynamicGroupService.GroupMembChangingProcess.MEMBERS_SELECTING) {
            query = EUR_CRM_DynamicGroupService.getMembChangingSelectingQuery(groupType, iterableSObjectIds, GROUP_MEMBERS_SCOPE_SIZE);
        } else if(process == EUR_CRM_DynamicGroupService.GroupMembChangingProcess.GROUPS_CHEKING) {
            query = EUR_CRM_DynamicGroupService.getDynamicGroupQuery(groupType, null, null);
        }

        return Database.getQueryLocator(query);
    }

    public override void execute(Database.BatchableContext ctx, List<SObject> scope) {
        if(process == EUR_CRM_DynamicGroupService.GroupMembChangingProcess.MEMBERS_SELECTING) {
            groupMembers = scope;
        } else if(process == EUR_CRM_DynamicGroupService.GroupMembChangingProcess.GROUPS_CHEKING) {
            EUR_CRM_DynamicGroupService.processGroupMembersChanging(groupMembers, scope);
        }
    }

    protected override Boolean runNextOnFinish() {
        Boolean isRunNextBatch = true;
        if(groupMembers == null || groupMembers.isEmpty()) return isRunNextBatch;

        if(process == EUR_CRM_DynamicGroupService.GroupMembChangingProcess.MEMBERS_SELECTING) {
            Database.executeBatch(new EUR_CRM_DynGroupMembChangingBatch(iterableCashes, groupMembers, EUR_CRM_DynamicGroupService.GroupMembChangingProcess.GROUPS_CHEKING), GROUPS_SCOPE_SIZE);
            isRunNextBatch = false;
        } else if(process == EUR_CRM_DynamicGroupService.GroupMembChangingProcess.GROUPS_CHEKING) {
            isRunNextBatch = true;
        }

        return isRunNextBatch;
    }

}