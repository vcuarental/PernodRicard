/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

public with sharing class EUR_CRM_IsLatest_Batch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject> {

    private String objectApiName;

    public EUR_CRM_IsLatest_Batch(String objectApiName) {
        this.objectApiName = objectApiName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (objectApiName == 'EUR_CRM_Visit__c' || objectApiName == 'EUR_CRM_Store_Audit__c' || objectApiName ==
                'EUR_CRM_Price_Audit__c' || objectApiName == 'EUR_CRM_POSM_Audit__c') {
            return Database.getQueryLocator([
                    SELECT Id
                    FROM EUR_CRM_Account__c
            ]);
        }
        if (objectApiName == 'EUR_CRM_Contract_Audit__c') {
            return Database.getQueryLocator([
                    SELECT Id
                    FROM EUR_CRM_Contract__c
            ]);
        }
        return null;
    }

    public void execute(Database.BatchableContext bc, List<SObject> parentRecords) {
        List<SObject> childRecords = this.getChildRecords(parentRecords);
        System.debug('\n\n childRecords size => ' + JSON.serializePretty(childRecords.size()) + '\n');

        Map<Id, List<SObject>> recordsMapByParentId = this.configureMapByParentId(childRecords);
        System.debug('\n\n recordsMapByParentId size => ' + JSON.serializePretty(recordsMapByParentId.size()) + '\n');

        List<SObject> toUpdate = this.updateAndGetIsLatestRecord(recordsMapByParentId);
        System.debug('\n\n toUpdate size => ' + JSON.serializePretty(toUpdate.size()) + '\n');
        System.debug('\n\n toUpdate => ' + JSON.serializePretty(recordsMapByParentId) + '\n');

        if (!toUpdate.isEmpty()) {
            Database.update(toUpdate, false);
        }
    }

    private Map<Id, List<SObject>> configureMapByParentId(List<SObject> childRecords) {
        Map<Id, List<SObject>> result = new Map<Id, List<SObject>>();
        String parentField = objectApiName == 'EUR_CRM_Contract_Audit__c' ? 'EUR_CRM_Contract__c' : 'EUR_CRM_Account__c';
        for (SObject record : childRecords) {
            if (result.containsKey((Id) record.get(parentField))) {
                result.get((Id) record.get(parentField)).add(record);
            } else {
                result.put((Id) record.get(parentField), new List<SObject>{
                        record
                });
            }
        }
        return result;
    }

    private List<SObject> updateAndGetIsLatestRecord(Map<Id, List<SObject>> recordsMapByParentId) {
        List<SObject> toUpdate = new List<SObject>();
        for (Id parentId : recordsMapByParentId.keySet()) {
            List<SObject> childsByParentId = recordsMapByParentId.get(parentId);
            if (childsByParentId.isEmpty()) {
                continue;
            }
            SObject tempIsLatestRecord = childsByParentId[0];
            String comparingField = objectApiName == 'EUR_CRM_Visit__c' ? 'EUR_CRM_Start_Datetime__c' : 'EUR_CRM_Audit_Datetime__c';
            if (objectApiName == 'EUR_CRM_Contract_Audit__c') {
                comparingField = 'CreatedDate';
            }
            for (SObject record : childsByParentId) {
                if ((Datetime) record.get(comparingField) > (Datetime) tempIsLatestRecord.get(comparingField)) {
                    tempIsLatestRecord = record;
                }
            }
            tempIsLatestRecord.put('EUR_CRM_Is_Latest__c', true);
            if (objectApiName != 'EUR_CRM_Visit__c') {
                tempIsLatestRecord.put('EUR_CRM_Status__c', 'Finished');
            }
            toUpdate.add(tempIsLatestRecord);
        }
        return toUpdate;
    }

    private List<SObject> getChildRecords(List<SObject> parentRecords) {
        System.debug('QUERY=== ' + 'SELECT Id, CreatedDate, '
                + (objectApiName == 'EUR_CRM_Visit__c' ? 'EUR_CRM_Start_Datetime__c' : 'EUR_CRM_Audit_Datetime__c')
                + (objectApiName == 'EUR_CRM_Contract_Audit__c' ? ', EUR_CRM_Contract__c' : ', EUR_CRM_Account__c')
                + 'FROM ' + objectApiName + ' WHERE ' + (objectApiName == 'EUR_CRM_Contract_Audit__c' ?
                'EUR_CRM_Contract__c' : 'EUR_CRM_Account__c') + ' IN :parentRecords');
        return Database.query('SELECT Id, CreatedDate, '
                + (objectApiName == 'EUR_CRM_Visit__c' ? 'EUR_CRM_Start_Datetime__c' : 'EUR_CRM_Audit_Datetime__c')
                + (objectApiName == 'EUR_CRM_Contract_Audit__c' ? ', EUR_CRM_Contract__c' : ', EUR_CRM_Account__c')
                + ' FROM ' + objectApiName + ' WHERE ' + (objectApiName == 'EUR_CRM_Contract_Audit__c' ?
                'EUR_CRM_Contract__c' : 'EUR_CRM_Account__c') + ' IN :parentRecords');
    }

}