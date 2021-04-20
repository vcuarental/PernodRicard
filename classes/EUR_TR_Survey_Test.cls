/**
 * Created by Murat Can on 24/08/2020.
 */

@IsTest
private class EUR_TR_Survey_Test {

    @TestSetup
    static void setup() { 
        EUR_TR_Account__c account = new EUR_TR_Account__c();

        account.Name = 'Test';

        insert account;

        EUR_TR_Survey__c template = new EUR_TR_Survey__c();

        template.EUR_TR_CaptureMoment__c = 'BeforeVisitEnd';
        template.EUR_TR_Description__c = 'Test_Template_Master';
        template.EUR_TR_ValidFrom__c = Date.today().addDays(-7);
        template.EUR_TR_ValidThru__c = Date.today().addDays(7);
        template.EUR_TR_IsScored__c = true;
        template.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateMaster').getRecordTypeId();

        insert template;

        EUR_TR_Survey__c templateForAllCountry = new EUR_TR_Survey__c();

        templateForAllCountry.EUR_TR_CaptureMoment__c = 'BeforeVisitEnd';
        templateForAllCountry.EUR_TR_Description__c = 'Test_For_All';
        templateForAllCountry.EUR_TR_ValidFrom__c = Date.today().addDays(-7);
        templateForAllCountry.EUR_TR_ValidThru__c = Date.today().addDays(7);
        templateForAllCountry.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateMaster').getRecordTypeId();
        templateForAllCountry.EUR_TR_ForAllCountry__c = true;

        insert templateForAllCountry;

        EUR_TR_Survey__c templateDetail1 = new EUR_TR_Survey__c();

        templateDetail1.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetail').getRecordTypeId();
        templateDetail1.EUR_TR_Description__c = 'Test';
        templateDetail1.EUR_TR_Max__c = 50;
        templateDetail1.EUR_TR_Min__c = 5;
        templateDetail1.EUR_TR_MinToEarnPoints__c = 5;
        templateDetail1.EUR_TR_MaxToEarnPoints__c = 55;
        templateDetail1.EUR_TR_PointsToEarn__c = 50;
        templateDetail1.EUR_TR_QuestionOrder__c = 1;
        templateDetail1.EUR_TR_QuestionType__c = 'Numeric';
        templateDetail1.EUR_TR_RelatedSurveyTemplate__c = template.Id;

        insert templateDetail1;

        EUR_TR_Survey__c templateDetail2 = new EUR_TR_Survey__c();

        templateDetail2.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetail').getRecordTypeId();
        templateDetail2.EUR_TR_Description__c = 'Test';
        templateDetail2.EUR_TR_QuestionOrder__c = 2;
        templateDetail2.EUR_TR_QuestionType__c = 'Radio';
        templateDetail2.EUR_TR_RelatedSurveyTemplate__c = template.Id;

        insert templateDetail2;

        EUR_TR_Survey__c templateDetail3 = new EUR_TR_Survey__c();

        templateDetail3.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetail').getRecordTypeId();
        templateDetail3.EUR_TR_Description__c = 'Test';
        templateDetail3.EUR_TR_Max__c = 50;
        templateDetail3.EUR_TR_Min__c = 5;
        templateDetail3.EUR_TR_MinToEarnPoints__c = 5;
        templateDetail1.EUR_TR_MaxToEarnPoints__c = 55;
        templateDetail3.EUR_TR_PointsToEarn__c = 50;
        templateDetail3.EUR_TR_QuestionOrder__c = 3;
        templateDetail3.EUR_TR_QuestionType__c = 'Text';
        templateDetail3.EUR_TR_RelatedSurveyTemplate__c = template.Id;

        insert templateDetail3;

        EUR_TR_Survey__c templateDetail4 = new EUR_TR_Survey__c();

        templateDetail4.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetail').getRecordTypeId();
        templateDetail4.EUR_TR_Description__c = 'Test';
        templateDetail4.EUR_TR_PointsToEarn__c = 50;
        templateDetail4.EUR_TR_QuestionType__c = 'Checkbox';
        templateDetail4.EUR_TR_AnswerCheckboxToEarnPoints__c = true;
        templateDetail4.EUR_TR_RelatedSurveyTemplate__c = template.Id;

        insert templateDetail4;

        EUR_TR_Survey__c templateDetailOption1 = new EUR_TR_Survey__c();

        templateDetailOption1.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetailOption').getRecordTypeId();
        templateDetailOption1.EUR_TR_Description__c = 'Test';
        templateDetailOption1.EUR_TR_QuestionOrder__c = 1;
        templateDetailOption1.EUR_TR_PointsToEarn__c = 10;
        templateDetailOption1.EUR_TR_RelatedTemplateDetail__c = templateDetail2.Id;

        insert templateDetailOption1;

        EUR_TR_Survey__c target = new EUR_TR_Survey__c();

        target.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();
        target.EUR_TR_RelatedAccount__c = account.Id;
        target.EUR_TR_TargetRelatedTemplate__c = template.Id;
        target.EUR_TR_IsCompleted__c = false;

        insert target;
    }

    @IsTest
    static void testListSurveysDetailsById() {
        EUR_TR_Survey__c template = getTemplate();
        EUR_TR_Survey__c survey = new EUR_TR_Survey__c();

        survey.EUR_TR_RelatedSurveyTemplate__c = template.Id;

        Test.startTest();

        EUR_TR_Survey.listSurveysDetailsById(JSON.serialize(survey));

        Test.stopTest();
    }

    @IsTest
    static void testListSurveysByAccountId() {
        EUR_TR_Account__c account = getAccount();
        EUR_TR_Survey__c survey = new EUR_TR_Survey__c();

        survey.EUR_TR_RelatedAccount__c = account.Id;

        Test.startTest();

        EUR_TR_Survey.listSurveysByAccountId(JSON.serialize(survey));

        Test.stopTest();
    }

    @IsTest
    static void testListSurveysByUserId() {
        EUR_TR_Survey__c survey = new EUR_TR_Survey__c();

        survey.OwnerId = UserInfo.getUserId();

        Test.startTest();

        EUR_TR_Survey.listSurveysByUserId(JSON.serialize(survey));

        Test.stopTest();
    }

    @IsTest
    static void testSaveSurveyAnswersFromMiddleware() {
        EUR_TR_Survey__c instanceMaster = [
                SELECT Id, EUR_TR_CaptureMoment__c, EUR_TR_Description__c, EUR_TR_ValidFrom__c,
                        EUR_TR_ValidThru__c
                FROM EUR_TR_Survey__c
                WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster'
                AND EUR_TR_Description__c = 'Test_Template_Master'
        ];

        instanceMaster.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_InstanceMaster').getRecordTypeId();
        instanceMaster.EUR_TR_SurveyRelatedTemplate__c = instanceMaster.Id;
        instanceMaster.Id = null;

        insert instanceMaster;

        List<EUR_TR_Survey__c> instanceDetails = [
                SELECT Id, EUR_TR_QuestionType__c, EUR_TR_Description__c, EUR_TR_Max__c, EUR_TR_Min__c,
                        EUR_TR_QuestionOrder__c, EUR_TR_RelatedSurveyTemplate__c,
                (
                        SELECT Id
                        FROM Options__r
                )
                FROM EUR_TR_Survey__c
                WHERE RecordType.DeveloperName = 'EUR_TR_TemplateDetail'
        ];

        for (EUR_TR_Survey__c instanceDetail : instanceDetails) {
            instanceDetail.EUR_TR_RelatedSurveyTemplateDetail__c = instanceDetail.Id;
            instanceDetail.Id = null;
            instanceDetail.EUR_TR_RelatedSurvey__c = instanceMaster.Id;
            instanceDetail.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_InstanceDetail').getRecordTypeId();

            switch on instanceDetail.EUR_TR_QuestionType__c {
                when 'Numeric' {
                    instanceDetail.EUR_TR_AnswerNumeric__c = 15;
                }
                when 'Radio' {
                    EUR_TR_Survey__c option = instanceDetail.Options__r[0];

                    instanceDetail.EUR_TR_AnswerRadio__c = option.Id;
                }
                when 'Text' {
                    instanceDetail.EUR_TR_AnswerText__c = 'Test Answer Text';
                }
                when 'Checkbox' {
                    instanceDetail.EUR_TR_AnswerCheckbox__c = true;
                }
            }
        }

        insert instanceDetails;

        EUR_TR_Survey__c instanceMasterRequest = [
                SELECT Id, EUR_TR_SurveyRelatedTemplate__c,
                (
                        SELECT Id, EUR_TR_QuestionType__c, EUR_TR_Mandatory__c, EUR_TR_AnswerRadio__c,
                                EUR_TR_AnswerMultiSelect__c, EUR_TR_RelatedSurveyTemplateDetail__c
                        FROM Answers__r
                )
                FROM EUR_TR_Survey__c
                WHERE Id = :instanceMaster.Id
                LIMIT 1
        ];

        instanceMasterRequest.EUR_TR_RelatedAccount__c = getAccount().Id;

        Test.startTest();

        EUR_TR_Survey.saveSurveyAnswersFromMiddleware(JSON.serialize(instanceMasterRequest));
        EUR_TR_Survey.commitSaveSurveyAnswersFromMiddleware(JSON.serialize(instanceMasterRequest));

        Test.stopTest();
    }

    @IsTest
    static void negativeTests() {
        Test.startTest();

        EUR_TR_Survey.listSurveysByAccountId('{}');
        EUR_TR_Survey.listSurveysByUserId('{}');
        EUR_TR_Survey.listSurveysDetailsById('{}');
        EUR_TR_Survey.saveSurveyAnswersFromMiddleware('{}');
        EUR_TR_Survey.commitSaveSurveyAnswersFromMiddleware('{}');

        Test.stopTest();
    }

    static EUR_TR_Survey__c getTemplate() {
        return [
                SELECT Id
                FROM EUR_TR_Survey__c
                WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster'
                LIMIT 1
        ];
    }

    static EUR_TR_Account__c getAccount() {
        return [
                SELECT Id
                FROM EUR_TR_Account__c
                LIMIT 1
        ];
    }
}