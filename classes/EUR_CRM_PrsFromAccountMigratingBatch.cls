global without sharing class EUR_CRM_PrsFromAccountMigratingBatch implements Database.Batchable<sObject> {

    global Map<String, String> accountToPrsSegmentationMapping;
    global Map<String, String> channelToRecordTypeMapping;

    public EUR_CRM_PrsFromAccountMigratingBatch(Map<String, String> accountToPrsSegmentationMapping, Map<String, String> channelToRecordTypeMapping) {
        this.accountToPrsSegmentationMapping = accountToPrsSegmentationMapping;
        this.channelToRecordTypeMapping = channelToRecordTypeMapping;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> accountFields = new List<String>();
        List<String> accountConditions = new List<String>();
        List<String> segmentationCondition = new List<String>();
        for(String accField : accountToPrsSegmentationMapping.keySet()) {
            String prsSegmentationField = accountToPrsSegmentationMapping.get(accField);
            accountFields.add(accField);
            accountConditions.add(accField + ' != null');
            segmentationCondition.add('(EUR_CRM_Account__r.' + accField + ' = null OR ' + prsSegmentationField + ' != null)');
        }

        String query ='SELECT Id, EUR_CRM_Channel__c, ' + String.join(accountFields, ', ') + ' ';
        query += 'FROM EUR_CRM_Account__c WHERE (';
        query += String.join(accountConditions, ' OR ');
        query += ') AND Id NOT IN (SELECT EUR_CRM_Account__c FROM EUR_CRM_PRS_Segmentation__c WHERE ';
        query += String.join(segmentationCondition, ' AND ');
        query += ')';
        System.debug('EUR_CRM_PrsFromAccountMigratingBatch start query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<Id, EUR_CRM_PRS_Segmentation__c> prsSegmentationByAccId = getPrsSegmentationByAccId(new Map<Id, sObject>(scope).keySet());
        Map<Id, EUR_CRM_PRS_Segmentation__c> prsSegmentationForUpsert = new Map<Id, EUR_CRM_PRS_Segmentation__c>();

        for(EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>)scope) {
            Boolean isChangedPrsSegment = false;
            EUR_CRM_PRS_Segmentation__c prsSegmentation = prsSegmentationByAccId.get(acc.Id);
            if(prsSegmentation == null) {
                String recordTypeName = (channelToRecordTypeMapping == null) ? null :
                    channelToRecordTypeMapping.get(acc.EUR_CRM_Channel__c);
                Id prsSegmentationRecordTypeId = (recordTypeName == null)? null :
                    Schema.SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
                prsSegmentation = new EUR_CRM_PRS_Segmentation__c(
                    EUR_CRM_Account__c = acc.Id,
                    recordTypeId = prsSegmentationRecordTypeId
                );
                isChangedPrsSegment = true;
            }
            for(String accField : accountToPrsSegmentationMapping.keySet()) {
                String prsSegmentationField = accountToPrsSegmentationMapping.get(accField);
                Id accountLookupId = (Id)acc.get(accField);
                Id prsSegmentationLookupId = (Id)prsSegmentation.get(prsSegmentationField);
                if(accountLookupId != null && accountLookupId != prsSegmentationLookupId) {
                    prsSegmentation.put(prsSegmentationField, accountLookupId);
                    isChangedPrsSegment = true;
                }
            }
            if(isChangedPrsSegment) {
                prsSegmentationForUpsert.put(acc.Id, prsSegmentation);
            }
        }

        System.debug('EUR_CRM_ProsToPrsMigratingBatch execute prsSegmentationForUpsert: ' + prsSegmentationForUpsert);
        upsert prsSegmentationForUpsert.values();
    }

    global void finish(Database.BatchableContext BC) {}

    private Map<Id, EUR_CRM_PRS_Segmentation__c> getPrsSegmentationByAccId(Set<Id> accIds) {
        Map<Id, EUR_CRM_PRS_Segmentation__c> prsSegmentationByAccId = new Map<Id, EUR_CRM_PRS_Segmentation__c>();
        String query =
            'SELECT EUR_CRM_Account__c, ' + String.join(accountToPrsSegmentationMapping.values(), ', ') + ' ' +
            'FROM EUR_CRM_PRS_Segmentation__c ' +
            'WHERE EUR_CRM_Account__c IN: accIds';

        for(EUR_CRM_PRS_Segmentation__c prsS : Database.query(query)) {
            prsSegmentationByAccId.put(prsS.EUR_CRM_Account__c, prsS);
        }
        return prsSegmentationByAccId;
    }
}