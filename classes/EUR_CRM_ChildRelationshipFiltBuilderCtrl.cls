public with sharing class EUR_CRM_ChildRelationshipFiltBuilderCtrl {

    private static Set<String> childRelationships = new Set<String>();

    @AuraEnabled
    public static String getChildRelationships(String sObjectName) {
        initSobjectRelationships(sObjectName);
        List<Relationship> childRelationships = new List<Relationship>();
        if (String.isNotEmpty(sObjectName)) {
            for (EUR_CRM_Custom_List_View_Setting__mdt clvs : [
                SELECT
                    MasterLabel,
                    EUR_CRM_Child_Relationship__c,
                    EUR_CRM_Related_List_Label__c,
                    EUR_CRM_Parent_Object__r.QualifiedApiName
                FROM EUR_CRM_Custom_List_View_Setting__mdt
                WHERE EUR_CRM_Parent_Object__r.QualifiedApiName = :sObjectName
                ORDER BY EUR_CRM_Related_List_Label__c
            ]) {
                System.debug('\n\n clvs => ' + JSON.serializePretty(clvs) + '\n');
                if (isCorrectRelationship(clvs.EUR_CRM_Child_Relationship__c)) {
                    Relationship relationship = new Relationship();
                    relationship.relationshipName = clvs.EUR_CRM_Child_Relationship__c;
                    relationship.relatedListName = clvs.EUR_CRM_Related_List_Label__c;
                    childRelationships.add(relationship);
                }
            }
        }
        return JSON.serialize(childRelationships);
    }

    private static void initSobjectRelationships(String sObjectName) {
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        if (sObj != null) {
            for (ChildRelationship childRelationship : sObj.getDescribe().getChildRelationships()) {
                childRelationships.add(childRelationship.getRelationshipName());
            }
        }
    }

    private static Boolean isCorrectRelationship(String relName) {
        return childRelationships.contains(relName);
    }

    private class Relationship {
        private String relationshipName;
        private String relatedListName;
    }

}