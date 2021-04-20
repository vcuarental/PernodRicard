/**
 * Created by YuriyRudenko on 10/1/2020.
 */
@IsTest
public with sharing class EUR_CRM_AdminConsoleLwcControllerTest {
    private static final String EUR_GB_FS_RTM = 'EUR_GB_FS_RTM'; //Account RTs

    @TestSetup
    private static void setup() {
        EUR_CRM_Account__c acc = makeAccount(EUR_GB_FS_RTM);
        insert acc;
    }

    @IsTest
    private static void setupTest() {
        List<EUR_CRM_Account__c> accounts = selectAccounts();
        System.assertEquals(1, accounts.size());
        System.assertEquals(false, accounts[0].EUR_CRM_ForceEmptyPVA__c);
        System.assertEquals('GB', accounts[0].EUR_CRM_Country_Code__c);
    }

    @IsTest
    private static void runUpdateAccountsForceEmptyPVA_Positive_Test() {
        System.assertEquals('Success', EUR_CRM_AdminConsoleLwcController.runUpdateAccountsForceEmptyPVA('GB'));
    }

    @IsTest
    private static void countAccountsToForceEmptyPVA_Positive_Test() {
        Integer count = EUR_CRM_AdminConsoleLwcController.countAccountsToForceEmptyPVA('GB');
        System.assertEquals(1, count);
    }

    @IsTest
    private static void countAccountsToForceEmptyPVA_Negative_Test() {
        Integer count = EUR_CRM_AdminConsoleLwcController.countAccountsToForceEmptyPVA('DE');
        System.assertEquals(0, count);
    }


    @IsTest
    private static void runUpdateAccountsForceEmptyPVA_Negative_Test() {

        Test.startTest();
        EUR_CRM_AdminConsoleLwcController.runUpdateAccountsForceEmptyPVA('DE');
        Test.stopTest();

        List<EUR_CRM_Account__c> updatedAccounts = selectAccounts();
        System.assertEquals(1, updatedAccounts.size());
        System.assertEquals(false, updatedAccounts[0].EUR_CRM_ForceEmptyPVA__c);
    }

    //Makers
    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
                Name = 'Test Name'
                , EUR_CRM_Postal_Code__c = '1122'
                , RecordTypeId = rtId
        );
    }

    //Selectors
    private static List<EUR_CRM_Account__c> selectAccounts() {
        return [
                SELECT Id
                        ,   EUR_CRM_ForceEmptyPVA__c
                        ,   EUR_CRM_Country_Code__c
                FROM EUR_CRM_Account__c

        ];
    }
}