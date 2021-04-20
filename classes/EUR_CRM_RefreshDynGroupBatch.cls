public without sharing class EUR_CRM_RefreshDynGroupBatch implements Database.Batchable<SObject>, Database.Stateful {

    private EUR_CRM_DynamicGroupService.GroupType groupType;

    public EUR_CRM_RefreshDynGroupBatch(){
        this.groupType = EUR_CRM_DynamicGroupService.GroupType.ACCOUNT;
    }

    public EUR_CRM_RefreshDynGroupBatch(EUR_CRM_DynamicGroupService.GroupType groupType){
        this.groupType = groupType;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
       // String query = EUR_CRM_DynamicGroupService.getGroupQuery(groupType, null, null);
        String query = EUR_CRM_DynamicGroupService.getDynamicGroupQuery(groupType, null, null);
        query = addCondition(query);
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;
    }

    public void execute(Database.BatchableContext ctx, List<SObject> scope) {
        EUR_CRM_DynamicGroupService.processRefreshGroup(scope);
    }

    public void finish(Database.BatchableContext ctx) {
        if(groupType==EUR_CRM_DynamicGroupService.GroupType.ACCOUNT){
            Database.executeBatch(new EUR_CRM_RefreshDynGroupBatch(EUR_CRM_DynamicGroupService.GroupType.PRODUCT));
        }
    }

    private String addCondition(String query){
        String isDailyRecalculationCondition = 'AND EUR_CRM_isDailyRecalculation__c = true ';
        String newQuery =
            query.substring(0, query.indexOf('ORDER BY LastModifiedDate DESC')) +
                isDailyRecalculationCondition +
                query.substring(query.indexOf('ORDER BY LastModifiedDate DESC'), query.length());
        return newQuery;
    }

}