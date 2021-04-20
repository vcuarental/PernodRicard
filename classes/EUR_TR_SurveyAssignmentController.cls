/**
 * Created by bsavcı on 8/27/2020.
 */

public with sharing class EUR_TR_SurveyAssignmentController {
    //Assign
    @AuraEnabled
    public static SurveyAssignmentResponse assignSurveyRequest(SurveyAssignmentRequest request) {
        //Validation
        if (String.isBlank(request.SelectedSurveyId)) {
            return new SurveyAssignmentResponse(false, messages.get('E1'), 'E1');
        }
        if (request.Accounts == null || request.Accounts.isEmpty()) {
            return new SurveyAssignmentResponse(false, messages.get('E2'), 'E2');
        }
        if (request.FromBatch == null && !getLatestBatchProcess().isEmpty()) {
            return new SurveyAssignmentResponse(false, messages.get('E3'), 'E3');
        }

        try {
            EUR_TR_Survey__c templateMaster = [
                    SELECT Id,EUR_TR_Mandatory__c
                    FROM EUR_TR_Survey__c
                    WHERE Id = :request.SelectedSurveyId
            ];
            Map<String, EUR_TR_Survey__c> existingTargetSurveysMap = getExistingTargetSurveysMap(request.Accounts, templateMaster.Id);
            List<EUR_TR_Survey__c> targetSurveys = new List<EUR_TR_Survey__c>();

            for (EUR_TR_Account__c account : request.Accounts) {
                if (!existingTargetSurveysMap.containsKey(account.Id + '_' + templateMaster.Id)) {
                    targetSurveys.add(new EUR_TR_Survey__c(RecordTypeId = templateTargetRecordTypeId,
                            EUR_TR_RelatedAccount__c = account.Id,
                            EUR_TR_TargetRelatedTemplate__c = templateMaster.Id,
                            EUR_TR_IsCompleted__c = false,
                            EUR_TR_Mandatory__c = templateMaster.EUR_TR_Mandatory__c));
                }
            }
            insert targetSurveys;
            return new SurveyAssignmentResponse(true, messages.get('S1'), 'S1');
        } catch (Exception ex) {
            System.debug('Error Message : ' + ex.getMessage());
            System.debug('Trace : ' + ex.getStackTraceString());
            System.debug('Request : ' + JSON.serialize(request));
            if (request.FromBatch != null && request.FromBatch) throw ex; //This Exception will be thrown intentionally to be able to see in logs
            return new SurveyAssignmentResponse(false, messages.get('E4') + ex.getMessage(), 'E4');
        }
    }
    @AuraEnabled
    public static BulkSurveyAssignmentResponse bulkAssignSurveyRequest(BulkSurveyAssignmentRequest request) {
        //Validation
        if (String.isBlank(request.SelectedSurveyId)) {
            return new BulkSurveyAssignmentResponse(false, messages.get('E1'), 'E1');
        }
        if (String.isBlank(request.Query)) {
            return new BulkSurveyAssignmentResponse(false, messages.get('E5'), 'E5');
        }
        if (!getLatestBatchProcess().isEmpty()) {
            return new BulkSurveyAssignmentResponse(false, messages.get('E3'), 'E3');
        }

        try {
            String batchProcessId = Database.executeBatch(new EUR_TR_SurveyAssignmentBatch(request.Query, request.SelectedSurveyId, 'Assign'), 10000);
            return new BulkSurveyAssignmentResponse(true, messages.get('S2'), 'S2', batchProcessId);
        } catch (Exception ex) {
            System.debug('Error Message : ' + ex.getMessage());
            System.debug('Trace : ' + ex.getStackTraceString());
            return new BulkSurveyAssignmentResponse(false, messages.get('E4') + ex.getMessage(), 'E4');
        }
    }

    //Remove Assignments
    @AuraEnabled
    public static SurveyAssignmentResponse removeSurveyAssignmentRequest(SurveyAssignmentRequest request) {
        //Validation
        if (request.TargetSurveys == null || request.TargetSurveys.isEmpty()) {
            return new SurveyAssignmentResponse(false, messages.get('E1'), 'E1');
        }
        if (request.FromBatch == null && !getLatestBatchProcess().isEmpty()) {
            return new SurveyAssignmentResponse(false, messages.get('E6'), 'E6');
        }

        try {
            delete request.TargetSurveys;
            return new SurveyAssignmentResponse(true, messages.get('S3'), 'S3');
        } catch (Exception ex) {
            System.debug('Error Message : ' + ex.getMessage());
            System.debug('Trace : ' + ex.getStackTraceString());
            if (request.FromBatch != null && request.FromBatch) throw ex; //This Exception will be thrown intentionally to be able to see in logs
            return new SurveyAssignmentResponse(false, messages.get('E4') + ex.getMessage(), 'E4');
        }
    }
    @AuraEnabled
    public static BulkSurveyAssignmentResponse bulkRemoveSurveyAssignmentRequest(BulkSurveyAssignmentRequest request) {
        //Validation
        System.debug(JSON.serialize(request));
        if (String.isBlank(request.Query)) {
            return new BulkSurveyAssignmentResponse(false, messages.get('E5'), 'E5');
        }
        if (!getLatestBatchProcess().isEmpty()) {
            return new BulkSurveyAssignmentResponse(false, messages.get('E6'), 'E6');
        }

        try {
            String batchProcessId = Database.executeBatch(new EUR_TR_SurveyAssignmentBatch(request.Query, 'Delete'), 10000);
            return new BulkSurveyAssignmentResponse(true, messages.get('S4'), 'S4', batchProcessId);
        } catch (Exception ex) {
            System.debug('Error Message : ' + ex.getMessage());
            System.debug('Trace : ' + ex.getStackTraceString());
            return new BulkSurveyAssignmentResponse(false, messages.get('E4') + ex.getMessage(), 'E4');
        }
    }

    @AuraEnabled
    public static List<AsyncApexJob> getLatestBatchProcess() {
        //Return list to avoid List has no rows for assignment to SObject error
        return [
                SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,CreatedDate,ParentJobId
                FROM AsyncApexJob
                WHERE ApexClass.Name = 'EUR_TR_SurveyAssignmentBatch'
                AND Status != 'Completed'
                AND ParentJobId = NULL
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
    }
    @AuraEnabled
    public static AsyncApexJob getBatchProcessesStatus(String batchProcessesId) {
        return [
                SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,CreatedDate,ParentJobId
                FROM AsyncApexJob
                WHERE Id = :batchProcessesId
                LIMIT 1
        ];
    }
    @AuraEnabled
    public static List<PicklistEntry> getSurveyOptions() {
        List<EUR_TR_Survey__c> surveys = [
                SELECT Id,EUR_TR_Description__c,EUR_TR_ValidFrom__c,EUR_TR_ValidThru__c
                FROM EUR_TR_Survey__c
                WHERE RecordType.DeveloperName = 'EUR_TR_TemplateMaster'
                AND EUR_TR_ValidThru__c >= TODAY
        ];
        List<PicklistEntry> picklistEntries = new List<PicklistEntry>();

        for (EUR_TR_Survey__c survey : surveys) {
            PicklistEntry picklistEntry = new PicklistEntry();
            picklistEntry.label = String.format('{0} - ({1} - {2})', new List<String>{
                    survey.EUR_TR_Description__c, String.valueOf(survey.EUR_TR_ValidFrom__c), String.valueOf(survey.EUR_TR_ValidThru__c)
            });
            picklistEntry.value = survey.Id;
            picklistEntries.add(picklistEntry);
        }

        return picklistEntries;
    }

    @AuraEnabled
    public static Boolean getSurveyAssignmentPagePermission() {
        Boolean hasPermissionToSurveyAssignment = false;
        List<PermissionSetAssignment> surveyAssignmentPermission = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
                AND PermissionSet.Name = 'EUR_TR_TradeToolSurveyAssignment'
        ];
        if (!surveyAssignmentPermission.isEmpty()) {
            hasPermissionToSurveyAssignment = true;
        }
        return hasPermissionToSurveyAssignment;
    }

    //Utils
    private static Map<String, EUR_TR_Survey__c> getExistingTargetSurveysMap(List<EUR_TR_Account__c> accounts, String templateMasterId) {
        List<EUR_TR_Survey__c> existingTargetSurveys = [
                SELECT Id,EUR_TR_RelatedAccount__c,EUR_TR_TargetRelatedTemplate__c
                FROM EUR_TR_Survey__c
                WHERE RecordTypeId = :templateTargetRecordTypeId
                AND EUR_TR_IsCompleted__c = FALSE
                AND EUR_TR_RelatedAccount__c = :accounts
                AND EUR_TR_TargetRelatedTemplate__c = :templateMasterId
        ];

        Map<String, EUR_TR_Survey__c> existingTargetSurveysMap = new Map<String, EUR_TR_Survey__c>();
        for (EUR_TR_Survey__c existingTargetSurvey : existingTargetSurveys) {
            String key = existingTargetSurvey.EUR_TR_RelatedAccount__c + '_' + existingTargetSurvey.EUR_TR_TargetRelatedTemplate__c;
            if (!existingTargetSurveysMap.containsKey(key)) {
                existingTargetSurveysMap.put(key, existingTargetSurvey);
            }
        }

        return existingTargetSurveysMap;
    }

    //Fields
    private final static Id templateTargetRecordTypeId = Schema.SObjectType.EUR_TR_Survey__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_TemplateTarget').getRecordTypeId();
    private final static Map<String, String> messages = new Map<String, String>{//S->Success W->Warning E->Error
            'E1' => 'Anket seçmeniz gerekmektedir.',
            'E2' => 'Listeden müşteri seçmeniz gerekmektedir.',
            'E3' => 'İşlem devam ederken anket atayamazsınız.',
            'E4' => 'Beklenmeyen bir hata meydana geldi. ',
            'E5' => 'İşlem için gerekli sorgu bulunamadı.',
            'E6' => 'İşlem devam ederken anket ataması kaldıramazsınız.',
            'S1' => 'Anket atama işlemi başarıyla gerçekleşti.',
            'S2' => 'Toplu anket atama süreci başladı. Durum ekranından süreci takip edebilirsiniz.',
            'S3' => 'Müşteri üzerinden anket silme işlemi başarıyla gerçekleşti.',
            'S4' => 'Toplu anket silme süreci başladı. Durum ekranından süreci takip edebilirsiniz.'
    };


    //Models
    public class SurveyAssignmentRequest {
        @AuraEnabled
        public List<EUR_TR_Account__c> Accounts { get; set; }
        @AuraEnabled
        public String SelectedSurveyId { get; set; }
        @AuraEnabled
        public List<EUR_TR_Survey__c> TargetSurveys { get; set; }//will be used for delete operations
        public Boolean FromBatch { get; set; }
    }

    public class BulkSurveyAssignmentRequest {
        @AuraEnabled
        public String Query { get; set; }
        @AuraEnabled
        public String SelectedSurveyId { get; set; }
    }

    public virtual class SurveyAssignmentResponse {
        @AuraEnabled
        public Boolean Success { get; set; }
        @AuraEnabled
        public String Message { get; set; }
        @AuraEnabled
        public String MessageCode { get; set; }

        public SurveyAssignmentResponse(Boolean success, String message, String messageCode) {
            this.Success = success;
            this.Message = message;
            this.MessageCode = messageCode;
        }
    }
    public class BulkSurveyAssignmentResponse extends SurveyAssignmentResponse {
        @AuraEnabled
        public String BatchProcessId { get; set; }

        public BulkSurveyAssignmentResponse(Boolean success, String message, String messageCode, String batchProcessId) {
            super(success, message, messageCode);
            this.BatchProcessId = batchProcessId;
        }
        public BulkSurveyAssignmentResponse(Boolean success, String message, String messageCode) {
            super(success, message, messageCode);
        }
    }

    public class PicklistEntry {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }
}