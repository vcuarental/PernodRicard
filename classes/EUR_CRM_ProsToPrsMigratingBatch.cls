global without sharing class EUR_CRM_ProsToPrsMigratingBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject> {

    private String accId;
    private String counrtyCode;
    private List<SegmentMapping> migratingMapping;
    global Map<String, String> channelToRecordTypeMapping;

    public EUR_CRM_ProsToPrsMigratingBatch(String counrtyCode, List<SegmentMapping> migratingMapping, Map<String, String> channelToRecordTypeMapping) {
        this.counrtyCode = counrtyCode;
        this.migratingMapping = migratingMapping;
        this.channelToRecordTypeMapping = channelToRecordTypeMapping;
    }

    public EUR_CRM_ProsToPrsMigratingBatch(String counrtyCode, List<SegmentMapping> migratingMapping, Map<String, String> channelToRecordTypeMapping, String accId) {
        this.counrtyCode = counrtyCode;
        this.migratingMapping = migratingMapping;
        this.channelToRecordTypeMapping = channelToRecordTypeMapping;
        this.accId = accId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> prosFields = new Set<String>();
        Set<String> segmentCondition = new Set<String>();
        for(SegmentMapping mmap : migratingMapping){
            String prosExternalFieldApiName = mmap.prosSegmentLookupApiName.replace('__c', '__r') + '.EUR_CRM_External_ID__c';
            prosFields.add(mmap.prosSegmentLookupApiName);
            prosFields.add(prosExternalFieldApiName);
            segmentCondition.add(prosExternalFieldApiName + ' IN ' + getSetJoinQueryCondition(mmap.exteralIdMapping.keySet()));
        }

        String query =
                'SELECT Id, EUR_CRM_Account__c, EUR_CRM_Account__r.EUR_CRM_Channel__c, ' + String.join(new List<String>(prosFields), ', ') + ' ' +
                        'FROM EUR_CRM_Pros_Segmentation__c ' +
                        'WHERE ' +
                        'EUR_CRM_Account__r.EUR_CRM_Country_Code__c = :counrtyCode AND ' +
                        '(' + String.join(new List<String>(segmentCondition), ' OR ') +  ')' +
                        'AND EUR_CRM_Account__r.EUR_CRM_Channel__c IN ' + getSetJoinQueryCondition(channelToRecordTypeMapping.keySet());
        if (String.isNotBlank(this.accId)) {
            query += ' AND EUR_CRM_Account__c = :accId';
        }
        System.debug('EUR_CRM_ProsToPrsMigratingBatch start query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id, EUR_CRM_PRS_Segmentation__c> prsSegmentationByAccId = getPrsSegmentationByAccId(getParentIds(scope, 'EUR_CRM_Account__c'));
        System.debug('\n prsSegmentationByAccId.size() => ' + prsSegmentationByAccId.size() + '\n');
        System.debug('\n prsSegmentationByAccId => ' + JSON.serializePretty(prsSegmentationByAccId) + '\n');
        Map<Id, EUR_CRM_PRS_Segmentation__c> prsSegmentationForUpsert = new Map<Id, EUR_CRM_PRS_Segmentation__c>();
        for(EUR_CRM_Pros_Segmentation__c prosSegmentation : (List<EUR_CRM_Pros_Segmentation__c>)scope) {
            Boolean isChangedPrsSegment = false;
            EUR_CRM_PRS_Segmentation__c prsSegmentation = prsSegmentationByAccId.get(prosSegmentation.EUR_CRM_Account__c);
            if(prsSegmentation == null) {
                String recordTypeName = channelToRecordTypeMapping.get(prosSegmentation.EUR_CRM_Account__r.EUR_CRM_Channel__c);
                Id prsSegmentationRecordTypeId = (recordTypeName == null) ? null :
                    Schema.SObjectType.EUR_CRM_PRS_Segmentation__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
                prsSegmentation = new EUR_CRM_PRS_Segmentation__c(
                    EUR_CRM_Account__c = prosSegmentation.EUR_CRM_Account__c,
                    recordTypeId = prsSegmentationRecordTypeId
                );
                isChangedPrsSegment = true;
            }
            for(SegmentMapping mmap : migratingMapping){
                SObject prosSegmentationRelation = prosSegmentation.getSObject(mmap.prosSegmentLookupApiName.replace('__c', '__r'));
                if(prosSegmentationRelation == null) continue;
                String prosExternalId = (String)prosSegmentationRelation.get('EUR_CRM_External_ID__c');
                String prsExternalId = mmap.exteralIdMapping.get(prosExternalId);
                Id prsExteralSObjId = mmap.prsExteralId.get(prsExternalId);

                if((Id)prsSegmentation.get(mmap.prsSegmentLookupApiName) != prsExteralSObjId) {
                    prsSegmentation.put(mmap.prsSegmentLookupApiName, prsExteralSObjId);
                    isChangedPrsSegment = true;
                }
            }
            if(isChangedPrsSegment) {
                prsSegmentationForUpsert.put(prsSegmentation.EUR_CRM_Account__c, prsSegmentation);
            }
        }

        System.debug('\n prsSegmentationForUpsert.size() => ' + prsSegmentationForUpsert.size() + '\n');
        System.debug('\n prsSegmentationForUpsert => ' + JSON.serializePretty(prsSegmentationForUpsert) + '\n');
        this.upsertRecords(prsSegmentationForUpsert.values());


     }

    global override void finish(Database.BatchableContext bc) {
        super.finish(bc);
    }

    private Map<Id, EUR_CRM_PRS_Segmentation__c> getPrsSegmentationByAccId(Set<Id> accIds) {
        Map<Id, EUR_CRM_PRS_Segmentation__c> prsSegmentationByAccId = new Map<Id, EUR_CRM_PRS_Segmentation__c>();

        Set<String> prsFields = new Set<String>();
        for(SegmentMapping mmap : migratingMapping){
            prsFields.add(mmap.prsSegmentLookupApiName);
        }

        String query =
            'SELECT EUR_CRM_Account__c, ' + String.join(new List<String>(prsFields), ', ') + ' ' +
            'FROM EUR_CRM_PRS_Segmentation__c ' +
            'WHERE EUR_CRM_Account__c IN: accIds';

        for(EUR_CRM_PRS_Segmentation__c prsS : Database.query(query)) {
            prsSegmentationByAccId.put(prsS.EUR_CRM_Account__c, prsS);
        }
        return prsSegmentationByAccId;
    }

    global class SegmentMapping {
        global String prosSegmentLookupApiName;
        global String prosSegmentSObjectApiName;
        global String prsSegmentLookupApiName;
        global String prsSegmentSObjectApiName;
        global Map<String, String> exteralIdMapping;
        global Map<String, Id> prsExteralId;

        public SegmentMapping(String prosSegmentLookupApiName, String prsSegmentLookupApiName, Map<String, String> exteralIdMapping) {
            this(prosSegmentLookupApiName, prosSegmentLookupApiName, prsSegmentLookupApiName, prsSegmentLookupApiName, exteralIdMapping);
        }

        public SegmentMapping(String prosSegmentLookupApiName, String prosSegmentSObjectApiName, String prsSegmentLookupApiName, String prsSegmentSObjectApiName, Map<String, String> exteralIdMapping) {
            this.prosSegmentLookupApiName = prosSegmentLookupApiName;
            this.prosSegmentSObjectApiName = prosSegmentSObjectApiName;
            this.prsSegmentLookupApiName = prsSegmentLookupApiName;
            this.prsSegmentSObjectApiName = prsSegmentSObjectApiName;
            this.exteralIdMapping = exteralIdMapping;
            populatePrsExteralId();
        }

        private void populatePrsExteralId() {
            prsExteralId = new Map<String, Id>();
            String query =
                'SELECT Id, EUR_CRM_External_ID__c ' +
                'FROM ' + prsSegmentSObjectApiName + ' ' +
                'WHERE EUR_CRM_External_ID__c IN ' +  getSetJoinQueryCondition(new Set<String>(exteralIdMapping.values()));
            for(SObject prsSegment : Database.query(query)) {
                prsExteralId.put((String)prsSegment.get('EUR_CRM_External_ID__c'), prsSegment.Id);
            }
        }
    }

    public static String getSetJoinQueryCondition(Set<String> ids) {
        return '(\'' + String.join(new List<String>(ids), '\',\'') + '\') ';
    }

    public static Set<Id> getParentIds(List<SObject> sObjects, String parentFieldName) {
        Set<Id> parentIds = new Set<Id>();
        if(sObjects == null || sObjects.isEmpty() || String.isEmpty(parentFieldName)) return parentIds;
        for(SObject sObj : sObjects) {
            Id parentId = (Id) sObj.get(parentFieldName);
            if(parentId != null) parentIds.add(parentId);
        }
        return parentIds;
    }
}