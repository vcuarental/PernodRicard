/**
 * Created by osman on 15.01.2021.
 */

@IsTest
private with sharing class EUR_TR_BulkIncentiveLoaderControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c activeAccount = new EUR_TR_Account__c();
        activeAccount.Name = 'incentive account';
        activeAccount.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        activeAccount.EUR_TR_Status__c = 'Aktif';
        activeAccount.EUR_TR_AccountCode__c = '991';
        insert activeAccount;

    }


    @IsTest
    static void insertIncentiveRecords_success() {

        EUR_TR_Account__c account = getAccount();

        EUR_TR_BulkIncentiveLoaderController.Incentive incentive = new EUR_TR_BulkIncentiveLoaderController.Incentive();
        incentive.brand = 'JAMESON';
        incentive.description = 'description';
        incentive.startDate = '01.11.2020';
        incentive.endDate = '01.11.2021';
        incentive.accountCode = account.EUR_TR_AccountCode__c;

        List<EUR_TR_BulkIncentiveLoaderController.Incentive> incentives = new List<EUR_TR_BulkIncentiveLoaderController.Incentive>{
                incentive
        };

        Test.startTest();
        {
            EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords(incentives);
        }
        Test.stopTest();

    }

    @IsTest
    static void testInsertIncentiveRecords_error_account_code_is_null() {

        EUR_TR_BulkIncentiveLoaderController.Incentive incentive = new EUR_TR_BulkIncentiveLoaderController.Incentive();
        incentive.brand = 'JAMESON';
        incentive.description = 'description';
        incentive.startDate = '01.11.2020';
        incentive.endDate = '01.11.2021';
        incentive.accountCode = null;

        List<EUR_TR_BulkIncentiveLoaderController.Incentive> incentives = new List<EUR_TR_BulkIncentiveLoaderController.Incentive>{
                incentive
        };

        Test.startTest();
        {
            EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords(incentives);
        }
        Test.stopTest();

    }

    @IsTest
    static void testInsertIncentiveRecords_error_start_date_is_null() {

        EUR_TR_Account__c account = getAccount();

        EUR_TR_BulkIncentiveLoaderController.Incentive incentive = new EUR_TR_BulkIncentiveLoaderController.Incentive();
        incentive.brand = 'JAMESON';
        incentive.description = 'description';
        incentive.startDate = null;
        incentive.endDate = '01.11.2021';
        incentive.accountCode = account.EUR_TR_AccountCode__c;

        List<EUR_TR_BulkIncentiveLoaderController.Incentive> incentives = new List<EUR_TR_BulkIncentiveLoaderController.Incentive>{
                incentive
        };

        Test.startTest();
        {
            EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords(incentives);
        }
        Test.stopTest();

    }

    @IsTest
    static void testInsertIncentiveRecords_error_end_date_is_null() {

        EUR_TR_Account__c account = getAccount();

        EUR_TR_BulkIncentiveLoaderController.Incentive incentive = new EUR_TR_BulkIncentiveLoaderController.Incentive();
        incentive.brand = 'JAMESON';
        incentive.description = 'description';
        incentive.startDate = '01.11.2020';
        incentive.endDate = null;
        incentive.accountCode = account.EUR_TR_AccountCode__c;

        List<EUR_TR_BulkIncentiveLoaderController.Incentive> incentives = new List<EUR_TR_BulkIncentiveLoaderController.Incentive>{
                incentive
        };

        Test.startTest();
        {
            EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords(incentives);
        }
        Test.stopTest();

    }

    @IsTest
    static void testInsertIncentiveRecords_error_end_date_is_smaller_than_start_date() {

        EUR_TR_Account__c account = getAccount();
        EUR_TR_BulkIncentiveLoaderController.Incentive incentive = new EUR_TR_BulkIncentiveLoaderController.Incentive();
        incentive.brand = 'JAMESON';
        incentive.description = 'description';
        incentive.startDate = '01.11.2021';
        incentive.endDate = '01.11.2020';
        incentive.accountCode = account.EUR_TR_AccountCode__c;

        List<EUR_TR_BulkIncentiveLoaderController.Incentive> incentives = new List<EUR_TR_BulkIncentiveLoaderController.Incentive>{
                incentive
        };


        Test.startTest();
        {
            EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords(incentives);
        }
        Test.stopTest();

    }

    @IsTest
    static void testInsertIncentiveRecords_error_brand_is_null() {

        EUR_TR_Account__c account = getAccount();

        EUR_TR_BulkIncentiveLoaderController.Incentive incentive = new EUR_TR_BulkIncentiveLoaderController.Incentive();
        incentive.brand = null;
        incentive.description = 'description';
        incentive.startDate = '01.11.2020';
        incentive.endDate = '01.11.2021';
        incentive.accountCode = account.EUR_TR_AccountCode__c;

        List<EUR_TR_BulkIncentiveLoaderController.Incentive> incentives = new List<EUR_TR_BulkIncentiveLoaderController.Incentive>{
                incentive
        };


        Test.startTest();
        {
            EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords(incentives);
        }
        Test.stopTest();

    }


    @IsTest
    static void testInsertIncentiveRecords_error_description_is_null() {

        EUR_TR_Account__c account = getAccount();

        EUR_TR_BulkIncentiveLoaderController.Incentive incentive = new EUR_TR_BulkIncentiveLoaderController.Incentive();
        incentive.brand = 'JAMESON';
        incentive.description = null;
        incentive.startDate = '01.11.2020';
        incentive.endDate = '01.11.2021';
        incentive.accountCode = account.EUR_TR_AccountCode__c;

        List<EUR_TR_BulkIncentiveLoaderController.Incentive> incentives = new List<EUR_TR_BulkIncentiveLoaderController.Incentive>{
                incentive
        };


        Test.startTest();
        {
            EUR_TR_BulkIncentiveLoaderController.insertIncentiveRecords(incentives);
        }
        Test.stopTest();

    }


    private static EUR_TR_Account__c getAccount() {
        return [SELECT Id,EUR_TR_AccountCode__c FROM EUR_TR_Account__c LIMIT 1];
    }


}