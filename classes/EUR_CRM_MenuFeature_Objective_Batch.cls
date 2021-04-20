/**
 * Created by Ilarion Tokarskyi on 04.01.2021.
 */

public with sharing class EUR_CRM_MenuFeature_Objective_Batch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject> {
    private List<EUR_CRM_GB_Objective__c> objectivesToInsert = new List<EUR_CRM_GB_Objective__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT RecordType.Name,
                        CreatedById,
                        EUR_CRM_Account__r.EUR_CRM_Country_Code__c,
                        EUR_CRM_Account__c
                FROM EUR_CRM_Menu_Feature__c
                WHERE EUR_CRM_Menu_Type__c = 'Main'
                AND EUR_CRM_End_Date__c = TODAY
                AND EUR_CRM_Coming_from_Head_Office__c = FALSE
        ]);
    }

    public void execute(Database.BatchableContext bc, List<EUR_CRM_Menu_Feature__c> records) {
        for (EUR_CRM_Menu_Feature__c menuFeature : records) {
            objectivesToInsert.add(createObjToInsert(menuFeature.RecordType.Name, menuFeature.CreatedById,
                    menuFeature.EUR_CRM_Account__r.EUR_CRM_Country_Code__c, menuFeature.EUR_CRM_Account__c));
        }
        insert objectivesToInsert;
    }

    private EUR_CRM_GB_Objective__c createObjToInsert(String rtName, Id ownerId, String countryCode, Id accId) {
        String recordTypeDevName = [
                SELECT EUR_CRM_Value__c
                FROM EUR_CRM_Record_Type_Map__mdt
                WHERE EUR_CRM_Class_name__c = 'EUR_CRM_MenuFeature_Objective_Batch'
                AND EUR_CRM_Key__c = :countryCode
                LIMIT 1
        ].EUR_CRM_Value__c;
        return new EUR_CRM_GB_Objective__c(
                Name = 'Main ' + rtName + ' has expired. Please create a new one.',
                EUR_CRM_Start_Date__c = Date.today(),
                EUR_CRM_End_Date__c = Date.today().addDays(90),
                EUR_CRM_Achieved__c = false,
                EUR_CRM_Account__c = accId,
                OwnerId = ownerId,
                RecordTypeId = Schema.SObjectType.EUR_CRM_GB_Objective__c.getRecordTypeInfosByName()
                        .get(recordTypeDevName).getRecordTypeId()
        );
    }
}