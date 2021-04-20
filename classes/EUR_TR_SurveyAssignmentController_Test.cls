/**
 * Created by bsavcı on 9/2/2020.
 */

@IsTest
private class EUR_TR_SurveyAssignmentController_Test {
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

    //assignSurveyRequest
    @IsTest
    static void assignSurveyRequest_Validation_SelectedSurveyId_ErrorTest() {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        EUR_TR_SurveyAssignmentController.SurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.assignSurveyRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void assignSurveyRequest_Validation_Accounts_ErrorTest() {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        request.SelectedSurveyId = 'TEST';
        EUR_TR_SurveyAssignmentController.SurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.assignSurveyRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void assignSurveyRequest_DML_ErrorTest() {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        request.SelectedSurveyId = 'Not Exist Id';
        request.Accounts = [SELECT Id FROM EUR_TR_Account__c];
        EUR_TR_SurveyAssignmentController.SurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.assignSurveyRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void assignSurveyRequest_SuccessTest() {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        request.SelectedSurveyId = [SELECT Id FROM EUR_TR_Survey__c WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster' LIMIT 1].Id;
        request.Accounts = [SELECT Id FROM EUR_TR_Account__c];
        EUR_TR_SurveyAssignmentController.SurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.assignSurveyRequest(request);
        System.assert(response.Success);
    }

    //bulkAssignSurveyRequest
    @IsTest
    static void bulkAssignSurveyRequest_Validation_SelectedSurveyId_ErrorTest() {
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest();
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.bulkAssignSurveyRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void bulkAssignSurveyRequest_Validation_Query_ErrorTest() {
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest();
        request.SelectedSurveyId = 'TEST';
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.bulkAssignSurveyRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void bulkAssignSurveyRequest_SuccessTest() {
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest();
        request.SelectedSurveyId = [SELECT Id FROM EUR_TR_Survey__c WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster' LIMIT 1].Id;
        request.Query = 'SELECT Id FROM EUR_TR_Account__c ';
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.bulkAssignSurveyRequest(request);
        System.assert(response.Success);
    }

    //removeSurveyAssignmentRequest
    @IsTest
    static void removeSurveyAssignmentRequest_Validation_TargetSurveys_ErrorTest() {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        EUR_TR_SurveyAssignmentController.SurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.removeSurveyAssignmentRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void removeSurveyAssignmentRequest_DML_ErrorTest() {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        request.TargetSurveys = (List<EUR_TR_Survey__c>) JSON.deserialize('[{"Name":"Test Target Survey without Id"}]', List<EUR_TR_Survey__c>.class);
        EUR_TR_SurveyAssignmentController.SurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.removeSurveyAssignmentRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void removeSurveyAssignmentRequest_SuccessTest() {
        EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.SurveyAssignmentRequest();
        request.TargetSurveys = [SELECT Id FROM EUR_TR_Survey__c WHERE RecordType.DeveloperName = 'EUR_TR_TemplateTarget'];
        EUR_TR_SurveyAssignmentController.SurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.removeSurveyAssignmentRequest(request);
        System.assert(response.Success);
    }

    //bulkRemoveSurveyAssignmentRequest
    @IsTest
    static void bulkRemoveSurveyAssignmentRequest_Validation_Query_ErrorTest() {
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest();
        request.SelectedSurveyId = 'TEST';
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.bulkRemoveSurveyAssignmentRequest(request);
        System.assert(!response.Success);
    }
    @IsTest
    static void bulkRemoveSurveyAssignmentRequest_SuccessTest() {
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest();
        request.Query = 'SELECT Id FROM EUR_TR_Survey__c WHERE RecordType.DeveloperName = \'EUR_TR_TemplateTarget\'' +
                ' AND EUR_TR_IsCompleted__c = FALSE ' +
                ' AND EUR_TR_RelatedAccount__c != NULL';
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.bulkRemoveSurveyAssignmentRequest(request);
        System.assert(response.Success);
    }

    //getBatchProcessesStatus
    @IsTest
    static void getBatchProcessesStatus_SuccessTest() {
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest request = new EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentRequest();
        request.SelectedSurveyId = [SELECT Id FROM EUR_TR_Survey__c WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster' LIMIT 1].Id;
        request.Query = 'SELECT Id FROM EUR_TR_Account__c ';
        EUR_TR_SurveyAssignmentController.BulkSurveyAssignmentResponse response = EUR_TR_SurveyAssignmentController.bulkAssignSurveyRequest(request);
        System.assert(response.Success);
        AsyncApexJob asyncApexJobs = EUR_TR_SurveyAssignmentController.getBatchProcessesStatus(response.BatchProcessId);
        System.assert(asyncApexJobs != null);
    }

    //getSurveyOptions
    @IsTest
    static void getSurveyOptions_SuccessTest() {
        System.assert(!EUR_TR_SurveyAssignmentController.getSurveyOptions().isEmpty());
    }

    @IsTest
    static void testGetSurveyAssignmentPagePermission() {
        Test.startTest();
        {
            EUR_TR_SurveyAssignmentController.getSurveyAssignmentPagePermission();
        }
        Test.stopTest();
    }

}