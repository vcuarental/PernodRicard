/**
 * Created by Murat Can on 28/08/2020.
 */

@IsTest
private class EUR_TR_CreateSurveyControllerTest {

    @IsTest
    static void testGetSurveyAndSaveSurvey() {
        EUR_TR_Survey__c master = new EUR_TR_Survey__c();

        master.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateMaster').getRecordTypeId();
        master.EUR_TR_Description__c = 'Test';
        master.EUR_TR_CaptureMoment__c = 'BeforeDayStart';
        master.EUR_TR_IsScored__c = true;
        master.EUR_TR_ValidFrom__c = Date.today();
        master.EUR_TR_ValidThru__c = Date.today().addDays(3);

        insert master;

        EUR_TR_Survey__c detailRadio = new EUR_TR_Survey__c();

        detailRadio.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetail').getRecordTypeId();
        detailRadio.EUR_TR_RelatedSurveyTemplate__c = master.Id;
        detailRadio.EUR_TR_QuestionOrder__c = 1;
        detailRadio.EUR_TR_Description__c = 'Test';
        detailRadio.EUR_TR_QuestionType__c = 'Radio';

        insert detailRadio;

        EUR_TR_Survey__c detailOption = new EUR_TR_Survey__c();

        detailOption.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetailOption').getRecordTypeId();
        detailOption.EUR_TR_RelatedTemplateDetail__c = detailRadio.Id;
        detailOption.EUR_TR_QuestionOrder__c = 1;
        detailOption.EUR_TR_Description__c = 'Test';

        insert detailOption;

        EUR_TR_Survey__c detailText = new EUR_TR_Survey__c();

        detailText.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetail').getRecordTypeId();
        detailText.EUR_TR_RelatedSurveyTemplate__c = master.Id;
        detailText.EUR_TR_QuestionOrder__c = 2;
        detailText.EUR_TR_Description__c = 'Test';
        detailText.EUR_TR_QuestionType__c = 'Text';

        insert detailText;

        Test.startTest();

        EUR_TR_CreateSurveyController.SurveyWrapper surveyWrapper = EUR_TR_CreateSurveyController.getSurvey(master.Id);
        EUR_TR_CreateSurveyController.getSurvey(detailRadio.Id);
        EUR_TR_CreateSurveyController.getSurvey(detailOption.Id);
        EUR_TR_CreateSurveyController.saveSurvey(JSON.serialize(surveyWrapper));

        surveyWrapper.deleteList = new List<EUR_TR_Survey__c>{detailOption};
        surveyWrapper.assignedUserIds = new Set<String>{UserInfo.getUserId()};
        EUR_TR_CreateSurveyController.saveSurvey(JSON.serialize(surveyWrapper));

        Test.stopTest();
    }

    @IsTest
    static void testGetUsers() {
        Test.startTest();

        EUR_TR_CreateSurveyController.getUsers();

        Test.stopTest();
    }
}