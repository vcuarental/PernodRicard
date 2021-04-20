public with sharing class EUR_CRM_DynGroupMembBatch extends EUR_CRM_CacheBatch {

    public static final Integer GROUP_MEMBERS_SCOPE_SIZE = 200;
    public static final Integer GROUPS_SCOPE_SIZE = 1;

    private EUR_CRM_DynamicGroupService.GroupType groupType;
    private SObject iterableGroup;
    private EUR_CRM_DynamicGroupService.GroupMembProcess process;

    protected override String getBathId() {
        return EUR_CRM_CacheBatchService.DYN_GROUP_MEMB_BATCH_ID;
    }

    protected override Integer getIterableCashesQuantity() {
        return GROUPS_SCOPE_SIZE;
    }

    protected override void scheduleBatch() {
        EUR_CRM_BatchService.scheduleBatch(this, GROUP_MEMBERS_SCOPE_SIZE, 'EUR_CRM_DynGroupMembBatch' + String.valueOf(groupType));
    }

    protected override void executeNextBatch() {
        Database.executeBatch(new EUR_CRM_DynGroupMembBatch(groupType), GROUP_MEMBERS_SCOPE_SIZE);
    }

    public EUR_CRM_DynGroupMembBatch(EUR_CRM_DynamicGroupService.GroupType groupType){
        this.groupType = groupType;
    }

    public EUR_CRM_DynGroupMembBatch(List<EUR_CRM_Cache__c> iterableCashes, SObject iterableGroup, EUR_CRM_DynamicGroupService.GroupMembProcess process){
        super(iterableCashes);
        this.iterableGroup = iterableGroup;
        this.groupType = EUR_CRM_DynamicGroupService.getGroupType(this.iterableGroup);
        this.process = process;
    }

    protected override Database.QueryLocator getQueryForStart(Set<Id> iterableSObjectIds) {
        Database.QueryLocator queryLocator = null;
        if(this.iterableGroup == null) {
            List<SObject> dynamicGroup = Database.query(getDynamicGroupIterationQuery(iterableSObjectIds));
            if(!dynamicGroup.isEmpty()) {
                iterableGroup = dynamicGroup[0];
            }
        }
        if(this.iterableGroup != null) {
            if(process == null) {
                process = EUR_CRM_DynamicGroupService.GroupMembProcess.DELETING;
            }

            String query = EUR_CRM_DynamicGroupService.getGroupMembersQuery(iterableGroup, process);
            if(!String.isEmpty(query)) queryLocator = Database.getQueryLocator(query);
        }

        return queryLocator;
    }

    public override void execute(Database.BatchableContext ctx, List<SObject> scope) {
        EUR_CRM_DynamicGroupService.processGroupMembers(scope, iterableGroup, process);
    }

    protected override Boolean runNextOnFinish() {
        Boolean isRunNextBatch = true;
        if(iterableGroup == null) return isRunNextBatch;

        if(process == EUR_CRM_DynamicGroupService.GroupMembProcess.DELETING) {
            Database.executeBatch(new EUR_CRM_DynGroupMembBatch(iterableCashes, iterableGroup, EUR_CRM_DynamicGroupService.GroupMembProcess.ADDING), GROUP_MEMBERS_SCOPE_SIZE);
            isRunNextBatch = false;
        }

        return isRunNextBatch;
    }

    private String getDynamicGroupIterationQuery(Set<Id> iterableSObjectIds) {
        return EUR_CRM_DynamicGroupService.getGroupQuery(groupType, iterableSObjectIds, GROUPS_SCOPE_SIZE);
    }

}