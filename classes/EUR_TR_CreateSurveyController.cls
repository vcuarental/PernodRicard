/**
 * Created by Murat Can on 25/08/2020.
 */

public class EUR_TR_CreateSurveyController {

    @AuraEnabled
    public static SurveyWrapper getSurvey(String recordId) {
        Id masterId;
        EUR_TR_Survey__c surveyRecord = [
                SELECT Id, RecordType.DeveloperName, EUR_TR_RelatedTemplateDetail__r.EUR_TR_RelatedSurveyTemplate__c,
                        EUR_TR_RelatedSurveyTemplate__c
                FROM EUR_TR_Survey__c
                WHERE Id = :recordId
        ];

        if (surveyRecord.RecordType.DeveloperName == 'EUR_TR_TemplateMaster') {
            masterId = surveyRecord.Id;
        } else if (surveyRecord.RecordType.DeveloperName == 'EUR_TR_TemplateDetail') {
            masterId = surveyRecord.EUR_TR_RelatedSurveyTemplate__c;
        } else if (surveyRecord.RecordType.DeveloperName == 'EUR_TR_TemplateDetailOption') {
            masterId = surveyRecord.EUR_TR_RelatedTemplateDetail__r.EUR_TR_RelatedSurveyTemplate__c;
        } else {
            throw new AuraHandledException('Bu kayıt tipi desteklenmiyor.');
        }

        SurveyWrapper surveyWrapper = new SurveyWrapper();

        surveyWrapper.master = [
                SELECT Id, EUR_TR_Description__c, EUR_TR_CaptureMoment__c, EUR_TR_Mandatory__c, EUR_TR_ValidFrom__c,
                        EUR_TR_ValidThru__c, EUR_TR_IsScored__c,
                (
                        SELECT Owner.Id, Owner.Name
                        FROM TargetedAccounts__r
                        WHERE EUR_TR_TargetRelatedTemplate__r.EUR_TR_CaptureMoment__c IN ('BeforeDayStart', 'BeforeDayEnd')
                )
                FROM EUR_TR_Survey__c
                WHERE Id = :masterId
        ];

        surveyWrapper.details = [
                SELECT Id, EUR_TR_QuestionType__c, EUR_TR_Description__c, EUR_TR_QuestionOrder__c, EUR_TR_Mandatory__c,
                        EUR_TR_PictureRequired__c, EUR_TR_Min__c, EUR_TR_Max__c, EUR_TR_MinToEarnPoints__c, EUR_TR_MaxToEarnPoints__c,
                        EUR_TR_PointsToEarn__c, EUR_TR_AnswerCheckboxToEarnPoints__c,
                (
                        SELECT Id, EUR_TR_Description__c, EUR_TR_QuestionOrder__c, EUR_TR_PointsToEarn__c, EUR_TR_AnswerRadioToEarnPoints__c
                        FROM Options__r
                        ORDER BY EUR_TR_QuestionOrder__c
                ),
                (
                        SELECT Id, Title, ContentDocumentId
                        FROM AttachedContentDocuments
                        ORDER BY CreatedDate
                )
                FROM EUR_TR_Survey__c
                WHERE EUR_TR_RelatedSurveyTemplate__c = :masterId
                ORDER BY EUR_TR_QuestionOrder__c
        ];

        return surveyWrapper;
    }

    @AuraEnabled
    public static SurveyWrapper saveSurvey(String surveyWrapperAsString) {
        System.debug('surveyWrapperAsString: ' + surveyWrapperAsString);
        return saveSurvey((SurveyWrapper) JSON.deserialize(surveyWrapperAsString, SurveyWrapper.class));
    }

    public static SurveyWrapper saveSurvey(SurveyWrapper surveyWrapper) {
        surveyWrapper.master.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateMaster').getRecordTypeId();
        Decimal maximumPoints = 0;

        EUR_TR_Survey__c master = surveyWrapper.master;
        System.debug('master: ' + master);
        upsert master;

        List<EUR_TR_Survey__c> details = new List<EUR_TR_Survey__c>();
        for (EUR_TR_Survey__c detail : surveyWrapper.details) {
            detail.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetail').getRecordTypeId();
            detail.EUR_TR_RelatedSurveyTemplate__c = master.Id;

            details.add(detail);

            if (detail.EUR_TR_PointsToEarn__c != null && master.EUR_TR_IsScored__c) {
                maximumPoints += detail.EUR_TR_PointsToEarn__c;
            }

            if (detail.EUR_TR_QuestionType__c == 'Text') {
                detail.EUR_TR_MinToEarnPoints__c = 1;
                detail.EUR_TR_MaxToEarnPoints__c = 10000;
            }
        }

        System.debug('details: ' + details);
        upsert details;

        List<EUR_TR_Survey__c> options = new List<EUR_TR_Survey__c>();
        for (EUR_TR_Survey__c detail : details) {
            if (detail.EUR_TR_QuestionType__c != 'Radio' && detail.EUR_TR_QuestionType__c != 'MultiSelect') {
                continue;
            }

            for (EUR_TR_Survey__c option : detail.Options__r) {
                option.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateDetailOption').getRecordTypeId();
                option.EUR_TR_RelatedTemplateDetail__c = detail.Id;

                options.add(option);
                if (option.EUR_TR_AnswerRadioToEarnPoints__c && option.EUR_TR_PointsToEarn__c != null && master.EUR_TR_IsScored__c) {
                    maximumPoints += option.EUR_TR_PointsToEarn__c;
                }
            }
        }

        if (master.EUR_TR_IsScored__c) {
            master.EUR_TR_PointsToEarn__c = maximumPoints;
        }

        update master;

        System.debug('options: ' + options);
        upsert options;

        if (surveyWrapper.deleteList != null && !surveyWrapper.deleteList.isEmpty()) {
            List<EUR_TR_Survey__c> deleteList = new List<EUR_TR_Survey__c>();
            for (EUR_TR_Survey__c survey : surveyWrapper.deleteList) {
                if (String.isNotBlank(survey.Id)) {
                    deleteList.add(survey);

                }
                if (survey.Options__r != null && !survey.Options__r.isEmpty()) {
                    for (EUR_TR_Survey__c option : survey.Options__r) {
                        if (String.isNotBlank(option.Id)) {
                            deleteList.add(option);
                        }
                    }
                }
            }

            System.debug('deleteList: ' + deleteList);
            delete deleteList;
        }

        if (surveyWrapper.assignedUserIds != null) {
            if (master.EUR_TR_CaptureMoment__c == 'BeforeDayStart' || master.EUR_TR_CaptureMoment__c == 'BeforeDayEnd') {
                List<EUR_TR_Survey__c> alreadyTargetedSurveys = [
                        SELECT OwnerId
                        FROM EUR_TR_Survey__c
                        WHERE RecordType.DeveloperName = 'EUR_TR_TemplateTarget'
                        AND EUR_TR_TargetRelatedTemplate__c = :master.Id
                ];

                for (EUR_TR_Survey__c target : alreadyTargetedSurveys) {
                    surveyWrapper.assignedUserIds.remove(target.OwnerId);
                }

                List<EUR_TR_Survey__c> assignedTargets = new List<EUR_TR_Survey__c>();
                for (String ownerId : surveyWrapper.assignedUserIds) {
                    EUR_TR_Survey__c target = new EUR_TR_Survey__c();

                    target.RecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();
                    target.EUR_TR_TargetRelatedTemplate__c = master.Id;
                    target.EUR_TR_Mandatory__c = master.EUR_TR_Mandatory__c;
                    target.OwnerId = ownerId;

                    assignedTargets.add(target);
                }

                insert assignedTargets;
            }
        }

        return surveyWrapper;
    }

    @AuraEnabled
    public static List<User> getUsers() {
        return [
                SELECT Id, Name
                FROM User
                WHERE Id IN (
                        SELECT EUR_TR_RelatedUser__c
                        FROM EUR_TR_Employee__c
                        WHERE EUR_TR_RelatedUser__c != NULL
                )
        ];
    }

    public class SurveyWrapper {
        @AuraEnabled public EUR_TR_Survey__c master {get; set;}
        @AuraEnabled public List<EUR_TR_Survey__c> details {get; set;}
        @AuraEnabled public List<EUR_TR_Survey__c> deleteList {get; set;}
        @AuraEnabled public Set<String> assignedUserIds {get; set;}
    }
}