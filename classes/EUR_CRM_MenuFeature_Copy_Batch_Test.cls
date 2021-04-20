/**
 * Created by Ilarion Tokarskyi on 04.01.2021.
 */

@IsTest
private class EUR_CRM_MenuFeature_Copy_Batch_Test {
    @TestSetup
    static void testSetup() {
        EUR_CRM_Account__c parentAccount = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_DE_On_Trade_B2B')[0];
        parentAccount.EUR_CRM_Copy_Main_Menu__c = true;
        parentAccount.EUR_CRM_Business_Type__c = 'Headquater';
        insert parentAccount;

        List<EUR_CRM_Account__c> childAccounts = EUR_CRM_TestClassUtilityHelper.createAccountsEU(2, 'EUR_DE_On_Trade_B2B');
        childAccounts[0].EUR_CRM_Parent_Account__c = parentAccount.Id;
        childAccounts[1].EUR_CRM_Parent_Account__c = parentAccount.Id;
        insert childAccounts;

        List<EUR_CRM_Menu_Feature__c> menuFeatures = createMenuFeatures(parentAccount.Id, 2);
        insert menuFeatures;

        List<EUR_CRM_Menu_Feature_Items__c> menuItems = createMenuItems(menuFeatures[0].Id, 2);
        insert menuItems;
    }
    @IsTest
    static void positiveBatchTest() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_MenuFeature_Copy_Batch());
        Test.stopTest();

        List<EUR_CRM_Menu_Feature__c> menuFeatures = [SELECT Id FROM EUR_CRM_Menu_Feature__c];
        List<EUR_CRM_Menu_Feature_Items__c> menuItems = [SELECT Id FROM EUR_CRM_Menu_Feature_Items__c];
        System.assertEquals(6, menuFeatures.size());
        System.assertEquals(6, menuItems.size());
    }

    private static List<EUR_CRM_Menu_Feature__c> createMenuFeatures(Id accId, Integer countOfObjects) {
        List<EUR_CRM_Menu_Feature__c> result = new List<EUR_CRM_Menu_Feature__c>();
        Id recId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Menu_Feature__c','EUR_CRM_Drinks_Menu');
        for (Integer i = 0; i < countOfObjects; i++) {
            result.add(new EUR_CRM_Menu_Feature__c(
                    EUR_CRM_Account__c = accId,
                    EUR_CRM_Start_Date__c = Date.today(),
                    EUR_CRM_End_Date__c = Date.today().addDays(90),
                    EUR_CRM_Menu_Type__c = 'Main',
                    EUR_CRM_Total_Number_of_Champagne__c = 5,
                    EUR_CRM_Total_Number_of_Drinks__c = 5,
                    EUR_CRM_Copied_for_child_accounts__c = FALSE,
                    RecordTypeId = recId
            ));
        }
        return result;
    }

    private static List<EUR_CRM_Menu_Feature_Items__c> createMenuItems(Id menuId, Integer countOfObjects) {
        List<EUR_CRM_Menu_Feature_Items__c> result = new List<EUR_CRM_Menu_Feature_Items__c>();
        for (Integer i = 0; i < countOfObjects; i++) {
            Id recId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Menu_Feature_Items__c','EUR_CRM_Drinks_Menu');
            result.add(new EUR_CRM_Menu_Feature_Items__c(
                    EUR_CRM_Menu_Feature__c = menuId,
                    EUR_CRM_Number_of_Drinks__c = 5,
                    RecordTypeId = recId
            ));
        }
        return result;
    }
}