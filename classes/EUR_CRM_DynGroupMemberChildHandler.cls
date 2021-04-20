/**
 * Created by Alona Riabchenko on 21-May-18.
 */

public with sharing class EUR_CRM_DynGroupMemberChildHandler {
    public  void onAfterInsert(List<SObject> records) {
        EUR_CRM_DynamicGroupService.updateDynGroupsByMemberChildren(records, null);
    }

    public  void onAfterUpdate(List<SObject> records,Map<Id, sObject> oldMap) {
        EUR_CRM_DynamicGroupService.updateDynGroupsByMemberChildren(records, oldMap);
    }

    public  void onAfterDelete(List<SObject> records) {
        EUR_CRM_DynamicGroupService.updateDynGroupsByMemberChildren(records, null);
    }

    public  void onAfterUndelete(List<SObject> records) {
        EUR_CRM_DynamicGroupService.updateDynGroupsByMemberChildren(records, null);
    }
}