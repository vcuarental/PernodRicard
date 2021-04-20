/**
 * Created by osman on 29.12.2020.
 */


@IsTest
public with sharing class EUR_TR_BulkCrossComplianceControllerTest {

    @TestSetup
    static void setup() {

        EUR_TR_Account__c activeAccount = new EUR_TR_Account__c();
        activeAccount.Name = 'test acc 1';
        activeAccount.RecordTypeId = Schema.SObjectType.EUR_TR_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_OffTrade').getRecordTypeId();
        activeAccount.EUR_TR_Status__c = 'Aktif';
        activeAccount.EUR_TR_AccountCode__c = '12313';
        insert activeAccount;

    }

    @IsTest
    static void testUpsertCrossComplianceItems() {

        EUR_TR_BulkCrossComplianceController.CrossCompliance crossCompliance = new EUR_TR_BulkCrossComplianceController.CrossCompliance();
        crossCompliance.AccountCode = '12313';
        crossCompliance.AccountName = 'test acc';
        crossCompliance.CR12JD = true;
        crossCompliance.BFWJWRL = true;
        crossCompliance.PassBells = true;
        crossCompliance.Wybo = true;
        crossCompliance.Abs = true;

        EUR_TR_BulkCrossComplianceController.CrossCompliance crossComplianceWithUnknownExternalId = new EUR_TR_BulkCrossComplianceController.CrossCompliance();
        crossComplianceWithUnknownExternalId.AccountCode = '#$£#$£#$£#1213';
        crossComplianceWithUnknownExternalId.AccountName = 'test acc';
        crossComplianceWithUnknownExternalId.CR12JD = true;
        crossComplianceWithUnknownExternalId.BFWJWRL = true;
        crossComplianceWithUnknownExternalId.PassBells = true;
        crossComplianceWithUnknownExternalId.Wybo = true;
        crossComplianceWithUnknownExternalId.Abs = true;

        EUR_TR_BulkCrossComplianceController.CrossCompliance crossComplianceWithEmptyAccountCode = new EUR_TR_BulkCrossComplianceController.CrossCompliance();
        crossComplianceWithEmptyAccountCode.AccountCode = '#$£#$£#$£#1213';
        crossComplianceWithEmptyAccountCode.AccountName = 'test acc';
        crossComplianceWithEmptyAccountCode.CR12JD = true;
        crossComplianceWithEmptyAccountCode.BFWJWRL = true;
        crossComplianceWithEmptyAccountCode.PassBells = true;
        crossComplianceWithEmptyAccountCode.Wybo = true;
        crossComplianceWithEmptyAccountCode.Abs = true;


        Test.startTest();
        {
            EUR_TR_BulkCrossComplianceController.upsertCrossComplianceItems(new List<EUR_TR_BulkCrossComplianceController.CrossCompliance>{
                    crossCompliance, crossComplianceWithUnknownExternalId, crossComplianceWithEmptyAccountCode
            });
        }
        Test.stopTest();

    }

}