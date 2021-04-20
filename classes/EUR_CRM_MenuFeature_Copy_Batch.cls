/**
 * Created by Ilarion Tokarskyi on 29.12.2020.
 */

public with sharing class EUR_CRM_MenuFeature_Copy_Batch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject> {
    private Map<Id, List<EUR_CRM_Menu_Feature__c>> menuFeaturesByAccId = new Map<Id, List<EUR_CRM_Menu_Feature__c>>();
    private Map<Id, EUR_CRM_Account__c> accMapWithChilds = new Map<Id, EUR_CRM_Account__c>();
    Map<EUR_CRM_Menu_Feature__c, List<EUR_CRM_Menu_Feature_Items__c>> itemsByMenuFeature = new Map<EUR_CRM_Menu_Feature__c,
            List<EUR_CRM_Menu_Feature_Items__c>>();
    private List<EUR_CRM_Menu_Feature__c> menuFeaturesToInsert = new List<EUR_CRM_Menu_Feature__c>();
    private List<EUR_CRM_Menu_Feature_Items__c> menuFeaturesItemsToInsert = new List<EUR_CRM_Menu_Feature_Items__c>();
    private List<EUR_CRM_Menu_Feature__c> menuFeaturesToUpdate = new List<EUR_CRM_Menu_Feature__c>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> validRt = this.getValidRecordTypes();
        return Database.getQueryLocator([
                SELECT EUR_CRM_Account__c,
                        EUR_CRM_Start_Date__c,
                        EUR_CRM_End_Date__c,
                        EUR_CRM_Menu_Type__c,
                        EUR_CRM_Total_Number_of_Champagne__c,
                        RecordTypeId,
                        CreatedById,
                        EUR_CRM_Total_Number_of_Drinks__c, (
                        SELECT EUR_CRM_Brand_Quality__c,
                                EUR_CRM_By_the_Glass__c,
                                EUR_CRM_Key_Serve__c,
                                EUR_CRM_Number_of_Drinks__c,
                                RecordTypeId,
                                CreatedById
                        FROM Menu_Feature_Products__r
                )
                FROM EUR_CRM_Menu_Feature__c
                WHERE EUR_CRM_Menu_Type__c = 'Main'
                AND EUR_CRM_Copied_for_child_accounts__c = FALSE
                AND EUR_CRM_Account__r.EUR_CRM_Copy_Main_Menu__c = TRUE
                AND (EUR_CRM_Account__r.EUR_CRM_Business_Type__c = 'Head Office'
                OR EUR_CRM_Account__r.EUR_CRM_Business_Type__c = 'Headquater')
                AND EUR_CRM_Account_Owner_Menu__c = TRUE
                AND RecordType.DeveloperName IN :validRt
        ]);
    }

    public void execute(Database.BatchableContext bc, List<EUR_CRM_Menu_Feature__c> records) {
        this.configureMaps(records);
        createCopiedMenuFeaturesForChildAccounts();
        insert menuFeaturesToInsert;

        createItemsToInsert();
        insert menuFeaturesItemsToInsert;

        update menuFeaturesToUpdate;
    }

    private void createCopiedMenuFeaturesForChildAccounts() {
        for (Id accId : menuFeaturesByAccId.keySet()) {
            List<EUR_CRM_Account__c> childsAccounts = accMapWithChilds.get(accId).Accounts__r;
            if (childsAccounts.isEmpty()) continue;
            List<EUR_CRM_Menu_Feature__c> menuFeatures = menuFeaturesByAccId.get(accId);
            for (EUR_CRM_Account__c childAcc : childsAccounts) {
                cloneMenuFeaturesWithItems(menuFeatures, childAcc.Id);
            }
        }
    }

    private void createItemsToInsert() {
        for (EUR_CRM_Menu_Feature__c menuFeature : itemsByMenuFeature.keySet()) {
            if (itemsByMenuFeature.get(menuFeature) == null) {
                continue;
            }
            for (EUR_CRM_Menu_Feature_Items__c item : itemsByMenuFeature.get(menuFeature)) {
                menuFeaturesItemsToInsert.add(this.createMenuItemForInsert(item, menuFeature.Id));
            }
        }
    }

    private void cloneMenuFeaturesWithItems(List<EUR_CRM_Menu_Feature__c> originalRecords, Id newAccId) {
        for (EUR_CRM_Menu_Feature__c menuFeature : originalRecords) {
            EUR_CRM_Menu_Feature__c copiedMenuFeature = this.createMenuFeatureForInsert(menuFeature, newAccId);
            menuFeaturesToInsert.add(copiedMenuFeature);
            if (!menuFeature.Menu_Feature_Products__r.isEmpty()) {
                itemsByMenuFeature.put(copiedMenuFeature, menuFeature.Menu_Feature_Products__r);
            }
            menuFeature.EUR_CRM_Copied_for_child_accounts__c = TRUE;
            if (!menuFeaturesToUpdate.contains(menuFeature)) {
                menuFeaturesToUpdate.add(menuFeature);
            }
        }
    }

    private void configureMaps(List<EUR_CRM_Menu_Feature__c> records) {
        for (EUR_CRM_Menu_Feature__c record : records) {
            if (menuFeaturesByAccId.containsKey(record.EUR_CRM_Account__c)) {
                menuFeaturesByAccId.get(record.EUR_CRM_Account__c).add(record);
            } else {
                menuFeaturesByAccId.put(record.EUR_CRM_Account__c, new List<EUR_CRM_Menu_Feature__c>{
                        record
                });
            }
        }
        accMapWithChilds = this.getAccountsMapWithChildAccounts(menuFeaturesByAccId.keySet());
    }

    private EUR_CRM_Menu_Feature__c createMenuFeatureForInsert(EUR_CRM_Menu_Feature__c originalRecord, Id accId) {
        return new EUR_CRM_Menu_Feature__c(
                EUR_CRM_Start_Date__c = originalRecord.EUR_CRM_Start_Date__c,
                EUR_CRM_End_Date__c = originalRecord.EUR_CRM_End_Date__c,
                EUR_CRM_Menu_Type__c = originalRecord.EUR_CRM_Menu_Type__c,
                EUR_CRM_Total_Number_of_Drinks__c = originalRecord.EUR_CRM_Total_Number_of_Drinks__c,
                EUR_CRM_Total_Number_of_Champagne__c = originalRecord.EUR_CRM_Total_Number_of_Champagne__c,
                EUR_CRM_Coming_from_Head_Office__c = true,
                EUR_CRM_Account__c = accId,
                RecordTypeId = originalRecord.RecordTypeId,
                CreatedById = originalRecord.CreatedById
        );
    }

    private EUR_CRM_Menu_Feature_Items__c createMenuItemForInsert(EUR_CRM_Menu_Feature_Items__c originalRecord, Id
            menuId) {
        return new EUR_CRM_Menu_Feature_Items__c(
                EUR_CRM_Menu_Feature__c = menuId,
                EUR_CRM_Brand_Quality__c = originalRecord.EUR_CRM_Brand_Quality__c,
                EUR_CRM_By_the_Glass__c = originalRecord.EUR_CRM_By_the_Glass__c,
                EUR_CRM_Key_Serve__c = originalRecord.EUR_CRM_Key_Serve__c,
                EUR_CRM_Number_of_Drinks__c = originalRecord.EUR_CRM_Number_of_Drinks__c,
                RecordTypeId = originalRecord.RecordTypeId,
                CreatedById = originalRecord.CreatedById
        );
    }

    private Map<Id, EUR_CRM_Account__c> getAccountsMapWithChildAccounts(Set<Id> accIds) {
        return new Map<Id, EUR_CRM_Account__c>([
                SELECT Id, (SELECT Id FROM Accounts__r)
                FROM EUR_CRM_Account__c
                WHERE Id IN :accIds
        ]) ;
    }

    private List<String> getValidRecordTypes() {
        List<EUR_CRM_CT_Menu_Feature__mdt> mdts = [SELECT EUR_CRM_Parent_Object_Record_Type__c FROM
                EUR_CRM_CT_Menu_Feature__mdt WHERE
                EUR_CRM_Copy_from_HO_option__c = TRUE];
        List<String> result = new List<String>();
        for (EUR_CRM_CT_Menu_Feature__mdt mdt:mdts) {
            result.add(mdt.EUR_CRM_Parent_Object_Record_Type__c);
        }
        return result;
    }
}