public with sharing class EUR_CRM_ChildRelationshipController {

    @AuraEnabled
    public static String describeRelationship(String parentSObjectName, String childRelationshipName) {
        EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper childFilter = null;
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(parentSObjectName);
        if (sObj != null) {
            for (ChildRelationship childRelationship : sObj.getDescribe().getChildRelationships()) {
                if (String.isNotEmpty(childRelationship.relationshipName) && childRelationship.relationshipName == childRelationshipName) {
                    childFilter = new EUR_CRM_FilterBuilderService.ChildObjectFilterWrapper();
                    childFilter.childRelationshipName = childRelationship.getRelationshipName();
                    childFilter.childRelationshipField = childRelationship.field.getDescribe().getName();
                    childFilter.objectName =  childRelationship.childSObject.getDescribe().getName();
                }
            }
        }
        return JSON.serialize(childFilter);
    }

}