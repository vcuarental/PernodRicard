/**
 * Created by osman on 15.01.2021.
 */

@IsTest
private with sharing class EUR_TR_IncentiveControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c account = new EUR_TR_Account__c();
        account.Name = 'incentive account';
        account.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        account.EUR_TR_Status__c = 'Aktif';
        account.EUR_TR_AccountCode__c = '991';
        insert account;

        EUR_TR_Incentive__c incentive = new EUR_TR_Incentive__c();
        incentive.EUR_TR_RelatedAccount__c = account.Id;
        incentive.EUR_TR_Brand__c = 'JAMESON';
        incentive.EUR_TR_DoNotShowMeAgain__c = false;
        incentive.EUR_TR_Description__c = 'Açıklama';
        incentive.EUR_TR_StartDate__c = Date.today();
        incentive.EUR_TR_EndDate__c = Date.today().addDays(3);
        insert incentive;

    }

    @IsTest
    static void testGetActiveIncentivesByAccountIdFromMiddleware_success() {

        EUR_TR_Account__c account = getAccount();
        Test.startTest();
        {
            EUR_TR_IncentiveController.getActiveIncentivesByAccountIdFromMiddleware(JSON.serialize(account));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetActiveIncentivesByAccountIdFromMiddleware_error_account_Id_is_null() {

        EUR_TR_Account__c account = getAccount();
        Test.startTest();
        {
            account.Id = null;
            EUR_TR_IncentiveController.getActiveIncentivesByAccountIdFromMiddleware(JSON.serialize(account));
        }
        Test.stopTest();

    }

    @IsTest
    static void testDoNotShowMeSelectedIncentivesFromMiddleware_success() {

        EUR_TR_Account__c account = getAccount();
        List<EUR_TR_Incentive__c> incentives = [
                SELECT Id
                FROM EUR_TR_Incentive__c
                WHERE EUR_TR_RelatedAccount__c = :account.Id
        ];
        Test.startTest();
        {
            account.Id = null;
            EUR_TR_IncentiveController.doNotShowMeSelectedIncentivesFromMiddleware(JSON.serialize(incentives));
        }
        Test.stopTest();

    }


    @IsTest
    static void testDoNotShowMeSelectedIncentivesFromMiddleware_error_empty_incentives() {

        List<EUR_TR_Incentive__c> incentives = new List<EUR_TR_Incentive__c>();
        Test.startTest();
        {
            EUR_TR_IncentiveController.doNotShowMeSelectedIncentivesFromMiddleware(JSON.serialize(incentives));
        }
        Test.stopTest();

    }

    @IsTest
    static void testGetAllIncentivesByAccountIdFromMiddleware_success() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_IncentiveController.IncentiveFilterRequest incentiveFilterRequest = new EUR_TR_IncentiveController.IncentiveFilterRequest();
        incentiveFilterRequest.accountId = account.Id;
        incentiveFilterRequest.orderDirection = EUR_TR_IncentiveController.IncentiveOrderDirection.ascending;
        incentiveFilterRequest.orderBy = EUR_TR_IncentiveController.IncentiveFilterOrderBy.startDate;


        Test.startTest();
        {
            EUR_TR_IncentiveController.getAllIncentivesByAccountIdFromMiddleware(JSON.serialize(incentiveFilterRequest));
        }
        Test.stopTest();

    }


    @IsTest
    static void testGetAllIncentivesByAccountIdFromMiddleware_error_account_Id_is_null() {

        EUR_TR_IncentiveController.IncentiveFilterRequest incentiveFilterRequest = new EUR_TR_IncentiveController.IncentiveFilterRequest();
        incentiveFilterRequest.accountId = null;
        incentiveFilterRequest.orderDirection = EUR_TR_IncentiveController.IncentiveOrderDirection.ascending;
        incentiveFilterRequest.orderBy = EUR_TR_IncentiveController.IncentiveFilterOrderBy.startDate;

        Test.startTest();
        {
            EUR_TR_IncentiveController.getAllIncentivesByAccountIdFromMiddleware(JSON.serialize(incentiveFilterRequest));
        }
        Test.stopTest();

    }


    private static EUR_TR_Account__c getAccount() {
        return [SELECT Id,EUR_TR_AccountCode__c FROM EUR_TR_Account__c LIMIT 1];
    }

}