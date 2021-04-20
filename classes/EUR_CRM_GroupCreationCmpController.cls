public with sharing class EUR_CRM_GroupCreationCmpController {

    @AuraEnabled
    public static String loadGroup(Id groupId, String sObjectName) {
        sObject groupRecord = queryGroup(groupId, sObjectName);
        System.debug('\n\n groupRecord => ' + JSON.serializePretty(groupRecord) + '\n');

        String filterCriterias = String.valueOf(groupRecord.get('EUR_CRM_Criteria__c'));

        if( ! String.isEmpty(filterCriterias)) {
            EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper pofw = (EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper) JSON.deserialize(filterCriterias, EUR_CRM_FilterBuilderService.ParentObjectFilterWrapper.class);
            System.debug('\n\n pofw => ' + JSON.serializePretty(pofw) + '\n');

            EUR_CRM_FilterBuilderService.substitutePickListValues(pofw.objectName, pofw.items, true);
            EUR_CRM_FilterBuilderService.substituteDateFormats(pofw.objectName, pofw.items, EUR_CRM_FilterBuilderService.DateFormatTypes.LOCALE);
            EUR_CRM_FilterBuilderService.substituteRecordTypeValues(pofw.objectName, pofw.items, true);

            if(pofw.childItems != null && ! pofw.childItems.isEmpty()) {
                for(String child : pofw.childItems.keySet()) {
                    EUR_CRM_FilterBuilderService.substitutePickListValues(pofw.childItems.get(child).objectName, pofw.childItems.get(child).items, true);
                    EUR_CRM_FilterBuilderService.substituteDateFormats(pofw.childItems.get(child).objectName, pofw.childItems.get(child).items, EUR_CRM_FilterBuilderService.DateFormatTypes.LOCALE);
                    EUR_CRM_FilterBuilderService.substituteRecordTypeValues(pofw.childItems.get(child).objectName, pofw.childItems.get(child).items, true);
                }
            }
            System.debug('\n\n pofw => ' + JSON.serializePretty(pofw) + '\n');
            groupRecord.put('EUR_CRM_Criteria__c', JSON.serialize(pofw));
        }

        System.debug('\n\n groupRecord => ' + JSON.serializePretty(groupRecord) + '\n');
        return JSON.serialize(groupRecord);
    }

    @AuraEnabled
    public static String saveGroup(sObject record) {
        System.debug('***** saveGroup = '+record);
        try {
            upsert record;
            return '{ "success": true, "recordId": "' + record.Id + '" }';
        } catch (Exception e) {
            return '{ "success": false, "message": "' + e.getMessage() + '" }';
        }
    }

    public static sObject queryGroup(Id groupId, String sObjectName) {
        String query = 'SELECT Id, Name, EUR_CRM_Criteria__c, EUR_CRM_IsDynamic__c' +
            ' FROM ' + sObjectName +
            ' WHERE Id = :groupId' +
            ' LIMIT 1';
        return Database.query(query);
    }

}