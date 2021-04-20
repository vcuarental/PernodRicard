/**
 * Created by Ilarion Tokarskyi on 04.11.2020.
 */

public with sharing class EUR_CRM_IsLatestBeforeUpdateService {
    private String objectApiName;
    private String parentField;
    private String comparingField;
    private Map<Id, SObject> oldRecordsById = new Map<Id, SObject>();
    private Map<Id, List<SObject>> recordsByParentId = new Map<Id, List<SObject>>();
    private Set<Id> parentIdsForUpdate = new Set<Id>();

    public EUR_CRM_IsLatestBeforeUpdateService(String objectApiName) {
        this.objectApiName = objectApiName;
        if (objectApiName == 'EUR_CRM_Visit__c') {
            parentField = 'EUR_CRM_Account__c';
            comparingField = 'EUR_CRM_Start_Datetime__c';
        } else if (objectApiName == 'EUR_CRM_Contract_Audit__c') {
            parentField = 'EUR_CRM_Contract__c';
            comparingField = 'EUR_CRM_Audit_Datetime__c';
        } else {
            parentField = 'EUR_CRM_Account__c';
            comparingField = 'EUR_CRM_Audit_Datetime__c';
        }
    }
    /* ========================================================= */
    /*     Interface (Is_Latest Logic)
    /* ========================================================= */
    public void setIsLatestByChangedStatus(List<SObject> newRecords, List<SObject> oldRecords) {
        this.configureSObjectMap(oldRecords);

        List<SObject> recordsWithChangedStatus = this.getRecordsWithChangedStatus(newRecords);
        System.debug('\n\n recordsWithChangedStatus size => ' + JSON.serializePretty(recordsWithChangedStatus.size()) + '\n');
        System.debug('\n\n recordsWithChangedStatus => ' + JSON.serializePretty(recordsWithChangedStatus) + '\n');
        if (recordsWithChangedStatus.isEmpty()) return;

        this.configureResultMap(recordsWithChangedStatus);
        System.debug('\n\n recordsByParentId map size => ' + JSON.serializePretty(recordsByParentId.size()) + '\n');
        System.debug('\n\n recordsByParentId map => ' + JSON.serializePretty(recordsByParentId) + '\n');

        List<SObject> newRecordsToUpdate = this.getIsLatestRecordsToUpdate(recordsWithChangedStatus);
        System.debug('\n\n newRecordsToUpdate size => ' + JSON.serializePretty(newRecordsToUpdate.size()) + '\n');
        System.debug('\n\n newRecordsToUpdate => ' + JSON.serializePretty(newRecordsToUpdate) + '\n');
        if (!parentIdsForUpdate.isEmpty()) {
            updateOldIsLatestRecords();
        }
    }
    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private void updateOldIsLatestRecords() {
        List<SObject> oldRecordsToUpdate = this.getIsLatestRecordsByParentField(parentIdsForUpdate);
        System.debug('\n\n oldRecordsToUpdate size => ' + JSON.serializePretty(oldRecordsToUpdate.size()) + '\n');
        System.debug('\n\n oldRecordsToUpdate => ' + JSON.serializePretty(oldRecordsToUpdate) + '\n');
        for (SObject oldRecord: oldRecordsToUpdate) {
            oldRecord.put('EUR_CRM_Is_Latest__c',false);
        }
        Database.update(oldRecordsToUpdate,false);
    }

    private List<SObject> getIsLatestRecordsToUpdate(List<SObject> recordWithChangedStatus) {
        List<SObject> result = new List<SObject>();
        for (Id parentId : recordsByParentId.keySet()) {
            List<SObject> recordsByParentId = recordsByParentId.get(parentId);
            if (recordsByParentId.isEmpty()) continue;
            SObject tempIsLatestRecord = recordsByParentId[0];
            for (SObject record : recordsByParentId) {
                if ((Datetime) record.get(comparingField) > (Datetime) tempIsLatestRecord.get(comparingField)) {
                    tempIsLatestRecord = record;
                }
            }
            if (recordWithChangedStatus.contains(tempIsLatestRecord)) {
                tempIsLatestRecord.put('EUR_CRM_Is_Latest__c', true);
                result.add(tempIsLatestRecord);
                parentIdsForUpdate.add((Id)tempIsLatestRecord.get(parentField));
            }
        }
        return result;
    }

    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */

    private List<SObject> getRecordsWithChangedStatus(List<SObject> newRecords) {
        List<SObject> result = new List<SObject>();
        for (SObject newRecord : newRecords) {
            SObject oldRecord = oldRecordsById.get((Id) newRecord.get('Id'));
            if (newRecord.get('EUR_CRM_Status__c') != oldRecord.get('EUR_CRM_Status__c') && newRecord.get
                    ('EUR_CRM_Status__c') == 'Finished' && newRecord.get('EUR_CRM_Is_Latest__c') != true) {
                result.add(newRecord);
            }
        }
        return result;
    }

    private void configureSObjectMap(List<SObject> oldRecords) {
        for (SObject oldRecord : oldRecords) {
            oldRecordsById.put((Id) oldRecord.get('Id'), oldRecord);
        }
    }

    private void configureResultMap(List<SObject> records) {
        for (SObject record : records) {
            if (recordsByParentId.containsKey((Id) record.get(parentField))) {
                recordsByParentId.get((Id) record.get(parentField)).add(record);
            } else {
                recordsByParentId.put((Id) record.get(parentField), new List<SObject>{
                        record
                });
            }
        }
        List<SObject> isLatestRecords = getIsLatestRecordsByParentField(recordsByParentId.keySet());
        for (SObject isLatestRecord : isLatestRecords) {
            recordsByParentId.get((Id) isLatestRecord.get(parentField)).add(isLatestRecord);
        }
    }
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<SObject> getIsLatestRecordsByParentField(Set<Id> parentIds) {
        String query = 'SELECT EUR_CRM_Is_Latest__c, ' + parentField + ', ' + comparingField + ' FROM ' +
                objectApiName + ' WHERE ' + parentField + ' IN: parentIds ' + 'AND EUR_CRM_Is_Latest__c = TRUE';
        System.debug('Query for select ==> ' + query);
        return Database.query(query);
    }
}