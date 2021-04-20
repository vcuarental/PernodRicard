/**
 * Created by Murat Can on 24/08/2020.
 */

public with sharing class EUR_TR_Survey {

    private static final Id instanceMasterRTId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_InstanceMaster').getRecordTypeId();
    private static final Id instanceDetailRTId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_InstanceDetail').getRecordTypeId();
    private static final Id templateTargetRTId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();
    private static final Id multiSelectOptionRTId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_MultiSelectOption').getRecordTypeId();

    public static SurveyPoints calculateSurveyPoint(Id surveyMasterId) {
        EUR_TR_Survey__c instanceMaster = [
                SELECT Id,
                        EUR_TR_SurveyRelatedTemplate__r.EUR_TR_PointsToEarn__c,
                        EUR_TR_SurveyRelatedTemplate__r.EUR_TR_IsScored__c
                FROM EUR_TR_Survey__c
                WHERE Id = :surveyMasterId
        ];

        if (!instanceMaster.EUR_TR_SurveyRelatedTemplate__r.EUR_TR_IsScored__c) {
            return new SurveyPoints();
        }

        List<EUR_TR_Survey__c> instanceDetails = [
                SELECT Id,
                        EUR_TR_Mandatory__c,
                        EUR_TR_AnswerText__c,
                        EUR_TR_AnswerRadio__c,
                        EUR_TR_QuestionType__c,
                        EUR_TR_PointsEarned__c,
                        EUR_TR_AnswerNumeric__c,
                        EUR_TR_QuestionOrder__c,
                        EUR_TR_AnswerCheckbox__c,
                        EUR_TR_AnswerMultiSelect__c,

                        EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_Mandatory__c,
                        EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_PointsToEarn__c,
                        EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_QuestionType__c,
                        EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_MinToEarnPoints__c,
                        EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_MaxToEarnPoints__c,
                        EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_AnswerCheckboxToEarnPoints__c,

                (
                        SELECT Id, EUR_TR_MultiSelectSelectedOption__c,
                                EUR_TR_MultiSelectSelectedOption__r.EUR_TR_PointsToEarn__c,
                                EUR_TR_MultiSelectSelectedOption__r.EUR_TR_AnswerRadioToEarnPoints__c
                        FROM MultiSelectSelectedOptions__r
                )
                FROM EUR_TR_Survey__c
                WHERE EUR_TR_RelatedSurvey__c = :surveyMasterId
                AND RecordType.DeveloperName = 'EUR_TR_InstanceDetail'
                ORDER BY EUR_TR_QuestionOrder__c
        ];

        Decimal totalPoints = 0;
        List<EUR_TR_Survey__c> multiSelectOptions = new List<EUR_TR_Survey__c>();
        for (EUR_TR_Survey__c instanceDetail : instanceDetails) {
            EUR_TR_Survey__c templateDetail = instanceDetail.EUR_TR_RelatedSurveyTemplateDetail__r;

            switch on templateDetail.EUR_TR_QuestionType__c {
                when 'Checkbox' {
                    if (!instanceDetail.EUR_TR_Mandatory__c && instanceDetail.EUR_TR_AnswerCheckbox__c == null) {
                        continue;
                    }

                    if (instanceDetail.EUR_TR_AnswerCheckbox__c == templateDetail.EUR_TR_AnswerCheckboxToEarnPoints__c) {
                        totalPoints += templateDetail.EUR_TR_PointsToEarn__c;
                        instanceDetail.EUR_TR_PointsEarned__c = templateDetail.EUR_TR_PointsToEarn__c;
                    }
                    else {
                        instanceDetail.EUR_TR_PointsEarned__c = 0;
                    }
                }
                when 'MultiSelect', 'Radio' {
                    Decimal multiSelectTotal = 0;

                    for (EUR_TR_Survey__c multiSelectOption : instanceDetail.MultiSelectSelectedOptions__r) {
                        EUR_TR_Survey__c selectedOption = multiSelectOption.EUR_TR_MultiSelectSelectedOption__r;

                        if (selectedOption.EUR_TR_AnswerRadioToEarnPoints__c) {
                            multiSelectTotal += selectedOption.EUR_TR_PointsToEarn__c;
                            multiSelectOption.EUR_TR_PointsEarned__c = selectedOption.EUR_TR_PointsToEarn__c;
                        } else {
                            multiSelectOption.EUR_TR_PointsEarned__c = 0;
                        }

                        multiSelectOptions.add(multiSelectOption);
                    }

                    if ((!instanceDetail.MultiSelectSelectedOptions__r.isEmpty() || instanceDetail.EUR_TR_Mandatory__c)) {
                        instanceDetail.EUR_TR_PointsEarned__c = multiSelectTotal;
                        totalPoints += multiSelectTotal;
                    }
                }
                when 'Numeric' {
                    if (!templateDetail.EUR_TR_Mandatory__c && instanceDetail.EUR_TR_AnswerNumeric__c == null) {
                        continue;
                    }

                    if ((templateDetail.EUR_TR_MinToEarnPoints__c <= instanceDetail.EUR_TR_AnswerNumeric__c) &&
                            (templateDetail.EUR_TR_MaxToEarnPoints__c >= instanceDetail.EUR_TR_AnswerNumeric__c))
                    {
                        instanceDetail.EUR_TR_PointsEarned__c = templateDetail.EUR_TR_PointsToEarn__c;
                        totalPoints += templateDetail.EUR_TR_PointsToEarn__c;
                    } else {
                        instanceDetail.EUR_TR_PointsEarned__c = 0;
                    }
                }
                when 'Text' {
                    if (!templateDetail.EUR_TR_Mandatory__c && String.isBlank(instanceDetail.EUR_TR_AnswerText__c)) {
                        continue;
                    }

                    if ((templateDetail.EUR_TR_MinToEarnPoints__c <= instanceDetail.EUR_TR_AnswerText__c.length()) &&
                            (templateDetail.EUR_TR_MaxToEarnPoints__c >= instanceDetail.EUR_TR_AnswerText__c.length()))
                    {
                        instanceDetail.EUR_TR_PointsEarned__c = templateDetail.EUR_TR_PointsToEarn__c;
                        totalPoints += templateDetail.EUR_TR_PointsToEarn__c;
                    } else {
                        instanceDetail.EUR_TR_PointsEarned__c = 0;
                    }
                }
                when else {
                    continue;
                }
            }

            System.debug(instanceDetail.EUR_TR_QuestionOrder__c + '. sorunun aldığı puan: ' + instanceDetail.EUR_TR_PointsEarned__c);
        }

        System.debug('Toplam Puan: ' + totalPoints);
        instanceMaster.EUR_TR_TotalPoints__c = totalPoints;

        update instanceMaster;
        update instanceDetails;
        update multiSelectOptions;

        SurveyPoints surveyPoints = new SurveyPoints();

        surveyPoints.totalPoints = totalPoints;
        surveyPoints.maxPoints = instanceMaster.EUR_TR_SurveyRelatedTemplate__r.EUR_TR_PointsToEarn__c;

        return surveyPoints;
    }

    /*
    Methods below moved from EUR_TR_MiddlewareController.
    Test methods are in EUR_TR_MiddlewareController_Test.
    */

    public static EUR_TR_MiddlewareController.PostServiceResponse listSurveysByAccountId(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse response = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_Survey__c requestSurvey = (EUR_TR_Survey__c) JSON.deserialize(requestBody, EUR_TR_Survey__c.class);
            String relatedAccount = requestSurvey.EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';

                return response;
            }

            List<EUR_TR_Survey__c> allCountrySurveys = [
                    SELECT Id, EUR_TR_Mandatory__c,
                    (
                            SELECT Id, EUR_TR_RelatedAccount__c
                            FROM TargetedAccounts__r
                            WHERE EUR_TR_RelatedAccount__c = :relatedAccount
                    )
                    FROM EUR_TR_Survey__c
                    WHERE EUR_TR_ForAllCountry__c = TRUE
                    AND EUR_TR_ValidFrom__c <= TODAY
                    AND EUR_TR_ValidThru__c >= TODAY
                    FOR UPDATE
            ];

            if (!allCountrySurveys.isEmpty()) {
                List<EUR_TR_Survey__c> targets = new List<EUR_TR_Survey__c>();

                for (EUR_TR_Survey__c survey : allCountrySurveys) {
                    if (survey.TargetedAccounts__r.isEmpty()) {
                        EUR_TR_Survey__c target = new EUR_TR_Survey__c();

                        target.RecordTypeId = templateTargetRTId;
                        target.EUR_TR_RelatedAccount__c = relatedAccount;
                        target.EUR_TR_TargetRelatedTemplate__c = survey.Id;
                        target.EUR_TR_Mandatory__c = survey.EUR_TR_Mandatory__c;
                        target.EUR_TR_IsCompleted__c = false;

                        targets.add(target);
                    }
                }

                insert targets;
            }

            List<EUR_TR_Survey__c> targetedSurveys = [
                    SELECT EUR_TR_TargetRelatedTemplate__c, EUR_TR_TargetRelatedTemplate__r.EUR_TR_Description__c, EUR_TR_Mandatory__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidFrom__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidThru__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_Mandatory__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_CaptureMoment__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_IsScored__c
                    FROM EUR_TR_Survey__c
                    WHERE EUR_TR_RelatedAccount__c = :relatedAccount
                    AND RecordType.DeveloperName = 'EUR_TR_TemplateTarget'
                    AND EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidFrom__c <= TODAY
                    AND EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidThru__c >= TODAY
                    AND EUR_TR_TargetRelatedTemplate__r.RecordType.DeveloperName = 'EUR_TR_TemplateMaster'
                    AND EUR_TR_IsCompleted__c = FALSE
                    ORDER BY EUR_TR_TargetRelatedTemplate__r.CreatedDate
            ];

            response.Code = 1;
            response.Message = EUR_TR_MiddlewareController.SuccessMessage;
            response.Data = targetedSurveys;

            return response;
        } catch (Exception exc) {
            Database.rollback(savepoint);
            System.debug(exc);

            response.Code = -1;
            response.Message = exc.getMessage();

            return response;
        }

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse listSurveysByUserId(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse response = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            EUR_TR_Survey__c requestSurvey = (EUR_TR_Survey__c) JSON.deserialize(requestBody, EUR_TR_Survey__c.class);

            if (String.isBlank(requestSurvey.OwnerId)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';

                return response;
            }

            List<EUR_TR_Survey__c> targetedSurveys = [
                    SELECT EUR_TR_TargetRelatedTemplate__c, EUR_TR_TargetRelatedTemplate__r.EUR_TR_Description__c, EUR_TR_Mandatory__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidFrom__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidThru__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_Mandatory__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_CaptureMoment__c,
                            EUR_TR_TargetRelatedTemplate__r.EUR_TR_IsScored__c
                    FROM EUR_TR_Survey__c
                    WHERE OwnerId = :requestSurvey.OwnerId
                    AND RecordType.DeveloperName = 'EUR_TR_TemplateTarget'
                    AND EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidFrom__c <= TODAY
                    AND EUR_TR_TargetRelatedTemplate__r.EUR_TR_ValidThru__c >= TODAY
                    AND EUR_TR_TargetRelatedTemplate__r.EUR_TR_CaptureMoment__c IN ('BeforeDayStart', 'BeforeDayEnd')
                    AND EUR_TR_TargetRelatedTemplate__r.RecordType.DeveloperName = 'EUR_TR_TemplateMaster'
                    AND EUR_TR_IsCompleted__c = FALSE
                    ORDER BY EUR_TR_TargetRelatedTemplate__r.CreatedDate
            ];

            response.Code = 1;
            response.Message = EUR_TR_MiddlewareController.SuccessMessage;
            response.Data = targetedSurveys;

            return response;
        } catch (Exception exc) {
            System.debug(exc);

            response.Code = -1;
            response.Message = exc.getMessage();

            return response;
        }

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse listSurveysDetailsById(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse response = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            EUR_TR_Survey__c requestSurvey = (EUR_TR_Survey__c) JSON.deserialize(requestBody, EUR_TR_Survey__c.class);
            String relatedSurvey = requestSurvey.EUR_TR_RelatedSurveyTemplate__c;

            if (String.isBlank(relatedSurvey)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedSurveyTemplate__c parametresi boş olamaz';

                return response;
            }

            List<EUR_TR_Survey__c> questions = [
                    SELECT Id, EUR_TR_Description__c, EUR_TR_QuestionOrder__c, EUR_TR_QuestionType__c, EUR_TR_Mandatory__c,
                            EUR_TR_PictureRequired__c, EUR_TR_Min__c, EUR_TR_Max__c,
                    (
                            SELECT Id, EUR_TR_Description__c, EUR_TR_QuestionOrder__c
                            FROM Options__r
                            ORDER BY EUR_TR_QuestionOrder__c
                    ),
                    (
                            SELECT ContentDocumentId, FileType
                            FROM AttachedContentDocuments
                    )
                    FROM EUR_TR_Survey__c
                    WHERE EUR_TR_RelatedSurveyTemplate__c = :relatedSurvey
                    ORDER BY EUR_TR_QuestionOrder__c
            ];

            response.Code = 1;
            response.Message = EUR_TR_MiddlewareController.SuccessMessage;
            response.Data = questions;

            return response;
        } catch (Exception exc) {
            response.Code = -1;
            response.Message = exc.getMessage();

            return response;
        }
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse saveSurveyAnswersFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_Survey__c masterSurvey = (EUR_TR_Survey__c) JSON.deserialize(requestBody, EUR_TR_Survey__c.class);

            serviceResponse.Code = 1;
            serviceResponse.ExtensionData = saveSurveyAnswers(masterSurvey);
        } catch (Exception exc) {
            System.debug(exc);
            Database.rollback(savepoint);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static EUR_TR_Survey__c saveSurveyAnswers(EUR_TR_Survey__c masterSurvey) {
        if (String.isBlank(masterSurvey.EUR_TR_SurveyRelatedTemplate__c)) {
            throw new SurveyException('EUR_TR_SurveyRelatedTemplate__c parametresi boş olamaz');
        }

        masterSurvey.RecordTypeId = instanceMasterRTId;
        masterSurvey.Id = null;

        insert masterSurvey;

        for (EUR_TR_Survey__c detail : masterSurvey.Answers__r) {
            if (String.isBlank(detail.EUR_TR_RelatedSurveyTemplateDetail__c)) {
                throw new SurveyException(detail.EUR_TR_QuestionOrder__c + ' nolu sorunun EUR_TR_RelatedSurveyTemplateDetail__c parametresi boş.');
            }

            detail.RecordTypeId = instanceDetailRTId;
            detail.EUR_TR_RelatedSurvey__c = masterSurvey.Id;
            detail.Id = null;
            detail.EUR_TR_RelatedSurveyTemplate__c = null;
        }

        insert masterSurvey.Answers__r;

        List<EUR_TR_Survey__c> selectedOptions = new List<EUR_TR_Survey__c>();
        for (EUR_TR_Survey__c detail : masterSurvey.Answers__r) {
            if (detail.EUR_TR_QuestionType__c != 'Radio' && detail.EUR_TR_QuestionType__c != 'MultiSelect') {
                continue;
            } else if (!detail.EUR_TR_Mandatory__c) {
                if (String.isBlank(detail.EUR_TR_AnswerRadio__c) && String.isBlank(detail.EUR_TR_AnswerMultiSelect__c)) {
                    continue;
                }
            }

            List<String> selectedOptionIds = new List<String>();

            if (detail.EUR_TR_QuestionType__c == 'Radio') {
                selectedOptionIds = new List<String>{detail.EUR_TR_AnswerRadio__c};
            } else if (detail.EUR_TR_QuestionType__c == 'MultiSelect') {
                selectedOptionIds = detail.EUR_TR_AnswerMultiSelect__c.split(';');
            }

            if (!selectedOptionIds.isEmpty()) {
                for (String selectedOptionId : selectedOptionIds) {
                    EUR_TR_Survey__c selectedOption = new EUR_TR_Survey__c();

                    selectedOption.RecordTypeId = multiSelectOptionRTId;
                    selectedOption.EUR_TR_MultiSelectSelectedOption__c = selectedOptionId;
                    selectedOption.EUR_TR_MultiSelectAnswer__c = detail.Id;

                    selectedOptions.add(selectedOption);
                }
            }
        }

        insert selectedOptions;

        return masterSurvey;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse commitSaveSurveyAnswersFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            EUR_TR_Survey__c masterSurvey = (EUR_TR_Survey__c) JSON.deserialize(requestBody, EUR_TR_Survey__c.class);

            serviceResponse.Code = 1;
            serviceResponse.ExtensionData = commitSaveSurveyAnswers(masterSurvey);
        } catch (Exception exc) {
            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static SurveyPoints commitSaveSurveyAnswers(EUR_TR_Survey__c masterSurveyRequest) {
        for (EUR_TR_Survey__c detailWithPicture : [
                SELECT Id, EUR_TR_QuestionOrder__c,
                (
                        SELECT Id
                        FROM AttachedContentDocuments
                )
                FROM EUR_TR_Survey__c
                WHERE EUR_TR_RelatedSurvey__c = :masterSurveyRequest.Id
                AND EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_PictureRequired__c = TRUE
                AND EUR_TR_RelatedSurveyTemplateDetail__r.EUR_TR_Mandatory__c = TRUE
        ]) {
            if (detailWithPicture.AttachedContentDocuments.isEmpty()) {
                throw new SurveyException(detailWithPicture.EUR_TR_QuestionOrder__c + '. sorunun fotoğraf yüklemesi tamamlanmamış.');
            }
        }

        EUR_TR_Survey__c surveyRelatedTemplate = [
                SELECT EUR_TR_CaptureMoment__c
                FROM EUR_TR_Survey__c
                WHERE Id = :masterSurveyRequest.EUR_TR_SurveyRelatedTemplate__c
        ];

        List<EUR_TR_Survey__c> target = new List<EUR_TR_Survey__c>();
        switch on surveyRelatedTemplate.EUR_TR_CaptureMoment__c {
            when 'BeforeDayStart', 'BeforeDayEnd' {
                target = [
                        SELECT Id
                        FROM EUR_TR_Survey__c
                        WHERE EUR_TR_TargetRelatedTemplate__c = :masterSurveyRequest.EUR_TR_SurveyRelatedTemplate__c
                        AND OwnerId = :UserInfo.getUserId()
                        AND EUR_TR_IsCompleted__c = FALSE
                        AND RecordType.DeveloperName = 'EUR_TR_TemplateTarget'
                        ORDER BY CreatedDate
                        LIMIT 1
                ];
            }
            when 'BeforeVisitStart', 'BeforeVisitEnd' {
                target = [
                        SELECT Id
                        FROM EUR_TR_Survey__c
                        WHERE EUR_TR_TargetRelatedTemplate__c = :masterSurveyRequest.EUR_TR_SurveyRelatedTemplate__c
                        AND EUR_TR_RelatedAccount__c = :masterSurveyRequest.EUR_TR_RelatedAccount__c
                        AND EUR_TR_IsCompleted__c = FALSE
                        AND RecordType.DeveloperName = 'EUR_TR_TemplateTarget'
                        ORDER BY CreatedDate
                        LIMIT 1
                ];
            }
        }

        if (target.isEmpty()) {
            throw new SurveyException('Anket ataması yapılmamış veya bu anket zaten tamamlanmış');
        }

        target[0].EUR_TR_IsCompleted__c = true;
        update target;

        return calculateSurveyPoint(masterSurveyRequest.Id);
    }

    public class SurveyPoints {
        public Decimal totalPoints { get; set; }
        public Decimal maxPoints {get; set;}
    }

    public class SurveyException extends Exception { }
}