/**
 * Created by Ilarion Tokarskyi on 04.01.2021.
 */

@IsTest
private class EUR_CRM_MenuFeature_Objective_Batch_Test {
    @TestSetup
    static void testSetup() {
        EUR_CRM_Account__c parentAccount = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR_GB_FS_Indirect')[0];
        parentAccount.EUR_CRM_Copy_Main_Menu__c = true;
        parentAccount.EUR_CRM_Business_Type__c = 'Headquater';
        insert parentAccount;
        List<EUR_CRM_Menu_Feature__c> menuFeatures = createMenuFeatures(parentAccount.Id, 2);
        insert menuFeatures;
    }
    @IsTest
    static void positiveBatchTest() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_MenuFeature_Objective_Batch());
        Test.stopTest();

        List<EUR_CRM_GB_Objective__c> objectives = [SELECT Id FROM EUR_CRM_GB_Objective__c];
        System.assertEquals(2, objectives.size());
    }

    private static List<EUR_CRM_Menu_Feature__c> createMenuFeatures(Id accId, Integer countOfObjects) {
        List<EUR_CRM_Menu_Feature__c> result = new List<EUR_CRM_Menu_Feature__c>();
        for (Integer i = 0; i < countOfObjects; i++) {
            result.add(new EUR_CRM_Menu_Feature__c(
                    EUR_CRM_Account__c = accId,
                    //EUR_CRM_Start_Date__c = Date.today(),
                    EUR_CRM_End_Date__c = Date.today(),
                    EUR_CRM_Menu_Type__c = 'Main',
                    EUR_CRM_Total_Number_of_Champagne__c = 5,
                    EUR_CRM_Total_Number_of_Drinks__c = 5,
                    EUR_CRM_Coming_from_Head_Office__c = FALSE
            ));
        }
        return result;
    }
}