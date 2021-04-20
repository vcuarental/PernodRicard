/**
 * Created by bsavcı on 9/2/2020.
 */

@IsTest
private class EUR_TR_SurveyAssignmentBatch_Test {
    @TestSetup
    static void setup() {
        //Create Accounts
        List<EUR_TR_Account__c> accounts = new List<EUR_TR_Account__c>();
        for (Integer i = 0; i < 100; i++) {
            accounts.add(new EUR_TR_Account__c(Name = 'TEST ' + i));
        }
        insert accounts;

        //Create Template Master
        Id templateMasterRecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateMaster').getRecordTypeId();
        EUR_TR_Survey__c templateMaster = new EUR_TR_Survey__c(RecordTypeId = templateMasterRecordTypeId,
                EUR_TR_Description__c = 'Test Template Master',
                EUR_TR_ValidFrom__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().addDays(-10).day()),
                EUR_TR_ValidThru__c = Date.today());
        insert templateMaster;

        //Create Target Survey
        Id templateTargetRecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();
        EUR_TR_Survey__c templateTarget = new EUR_TR_Survey__c(RecordTypeId = templateTargetRecordTypeId, EUR_TR_Description__c = 'Test Template Target',
                EUR_TR_RelatedAccount__c = accounts[0].Id,
                EUR_TR_TargetRelatedTemplate__c = templateMaster.Id,
                EUR_TR_IsCompleted__c = false);
        insert templateTarget;
    }

    @IsTest
    static void start_Assign_SuccessTest() {
        Database.executeBatch(new EUR_TR_SurveyAssignmentBatch('SELECT Id FROM EUR_TR_Account__c',
                [SELECT Id FROM EUR_TR_Survey__c WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster' LIMIT 1].Id,
                'Assign'), 10000);
    }

    @IsTest
    static void start_Delete_SuccessTest() {
        Database.executeBatch(new EUR_TR_SurveyAssignmentBatch('SELECT Id FROM EUR_TR_Survey__c WHERE RecordType.DeveloperName = \'EUR_TR_TemplateTarget\'' +
                ' AND EUR_TR_IsCompleted__c = FALSE ' +
                ' AND EUR_TR_RelatedAccount__c != NULL',
                'Delete'), 10000);
    }
}