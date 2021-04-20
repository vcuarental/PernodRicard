/**
 * Created by osman on 30.12.2020.
 */

@IsTest
private with sharing class EUR_TR_CrossComplianceControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c activeAccount = new EUR_TR_Account__c();
        activeAccount.Name = 'test acc 1';
        activeAccount.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        activeAccount.EUR_TR_Status__c = 'Aktif';
        activeAccount.EUR_TR_AccountCode__c = '875533';
        insert activeAccount;

        EUR_TR_CrossCompliance__c crossCompliance = new EUR_TR_CrossCompliance__c();
        crossCompliance.EUR_TR_CR12JD__c = true;
        crossCompliance.EUR_TR_BFWJWRL__c = true;
        crossCompliance.EUR_TR_PassBells__c = true;
        crossCompliance.EUR_TR_WyboCross__c = true;
        crossCompliance.EUR_TR_AbsCross__c = true;
        crossCompliance.EUR_TR_RelatedAccount__c = activeAccount.Id;
        insert crossCompliance;

    }

    @IsTest
    static void testGetListOfCrossComplianceByAccountIdFromMiddleware() {

        EUR_TR_Account__c account = [
                SELECT Id,Name
                FROM EUR_TR_Account__c
                LIMIT 1
        ];

        Test.startTest();
        {
            EUR_TR_CrossComplianceController.getCrossComplianceByAccountIdFromMiddleware(JSON.serializePretty(account));
        }
        Test.stopTest();


    }

    @IsTest
    static void testGetListOfCrossComplianceByAccountIdFromMiddleware_error_emptyRequest() {

        Test.startTest();
        {
            EUR_TR_CrossComplianceController.getCrossComplianceByAccountIdFromMiddleware('');
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetListOfCrossComplianceByAccountIdFromMiddleware_error_emptyAccountId() {

        EUR_TR_Account__c account = [
                SELECT Id,Name
                FROM EUR_TR_Account__c
                LIMIT 1
        ];

        Test.startTest();
        {
            account.Id = null;
            EUR_TR_CrossComplianceController.getCrossComplianceByAccountIdFromMiddleware(JSON.serializePretty(account));
        }
        Test.stopTest();


    }

}