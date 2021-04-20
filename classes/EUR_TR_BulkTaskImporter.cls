/**
 * Created by Murat Can on 11/09/2020.
 */

public with sharing class EUR_TR_BulkTaskImporter {

    @AuraEnabled
    public static BulkTaskSaveResult saveTasks(List<TaskWrapper> taskWrapperChunk, String predefinedTaskId, String importType, List<File> files) {
        BulkTaskSaveResult bulkTaskSaveResult = new BulkTaskSaveResult();

        Set<String> accountCodes = new Set<String>();
        Set<String> usernames = new Set<String>();
        for (TaskWrapper item : taskWrapperChunk) {
            if (item.What_EUR_TR_AccountCode != null) {
                accountCodes.add(item.What_EUR_TR_AccountCode);
            }
            if (importType == ImportTypes.fastTrack.name() && item.Username != null) {
                usernames.add(item.Username);
            }
        }

        List<EUR_TR_Account__c> accounts = [
                SELECT Id, EUR_TR_AccountCode__c, OwnerId
                FROM EUR_TR_Account__c
                WHERE EUR_TR_AccountCode__c IN :accountCodes
        ];

        Map<String, EUR_TR_Account__c> accountsMap = new Map<String, EUR_TR_Account__c>();
        for (EUR_TR_Account__c account : accounts) {
            accountsMap.put(account.EUR_TR_AccountCode__c, account);
        }

        List<User> users = [
                SELECT Id, Username
                FROM User
                WHERE Username IN :usernames
        ];

        Map<String, User> usersMap = new Map<String, User>();
        for (User user : users) {
            usersMap.put(user.Username, user);
        }

        EUR_TR_Definition__c predefinedTask = null;
        Boolean hasPredefinedTask = String.isNotEmpty(predefinedTaskId);
        if (hasPredefinedTask) {
            predefinedTask = [
                    SELECT EUR_TR_TaskType__c,EUR_TR_TaskDescription__c, EUR_TR_ActivityDate__c
                    FROM EUR_TR_Definition__c
                    WHERE Id = :predefinedTaskId
            ];
        }

        Map<Integer, Integer> rowNumberMap = new Map<Integer, Integer>();
        List<Task> tasks = new List<Task>();

        for (Integer rowNumber = 0; rowNumber < taskWrapperChunk.size(); rowNumber++) {
            TaskWrapper taskWrapper = taskWrapperChunk[rowNumber];

            EUR_TR_Account__c account = accountsMap.get(taskWrapper.What_EUR_TR_AccountCode);
            User owner = usersMap.get(taskWrapper.Username);

            if (importType == ImportTypes.fastTrack.name() && owner == null) {
                bulkTaskSaveResult.errorRows.add(rowNumber);
                continue;
            }

            if (account == null || taskWrapper.ActivityDate == null) {
                bulkTaskSaveResult.errorRows.add(rowNumber);
                continue;
            }

            if (predefinedTaskId == null && String.isEmpty(taskWrapper.Description)) {
                bulkTaskSaveResult.errorRows.add(rowNumber);
                continue;
            }

            Task task = new Task();

            task.WhatId = account.Id;
            task.ActivityDate = taskWrapper.ActivityDate;
            task.Cliente__c = taskWrapper.Cliente;
            task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('EUR_TR_Task').getRecordTypeId();
            task.Subject = 'Other';
            task.Status = 'Not started';
            task.Priority = 'Normal';

            if (importType == ImportTypes.fastTrack.name()) {
                task.OwnerId = owner.Id;
                task.PR_Activity_Type__c = 'Salesforce';
            } else if (importType == ImportTypes.preseller.name()) {
                task.OwnerId = account.OwnerId;
                task.PR_Activity_Type__c = 'Preseller';
            }

            if (hasPredefinedTask) {
                task.Cliente__c = predefinedTask.EUR_TR_TaskType__c;
                task.Description = predefinedTask.EUR_TR_TaskDescription__c;
                task.ActivityDate = predefinedTask.EUR_TR_ActivityDate__c;
            } else {
                task.Description = taskWrapper.Description;
            }

            rowNumberMap.put(tasks.size(), rowNumber);
            tasks.add(task);
        }

        List<Database.SaveResult> saveResults = Database.insert(tasks, false);

        if (files != null && !files.isEmpty()) {
            uploadAttachedFiles(files, tasks);
        }

        for (Integer resultIndex = 0; resultIndex < saveResults.size(); resultIndex++) {
            Database.SaveResult saveResult = saveResults[resultIndex];

            if (saveResult.isSuccess()) {
                bulkTaskSaveResult.successSize++;
            } else {
                for (Database.Error error : saveResult.errors) {
                    System.debug(String.format('StatusCode:{0}, fields:{1}, message:{2}', new List<String>{
                            String.valueOf(error.statusCode),
                            String.join(error.fields, ','),
                            error.message
                    }));
                }

                bulkTaskSaveResult.errorRows.add(rowNumberMap.get(resultIndex));
            }
        }

        bulkTaskSaveResult.errorSize = bulkTaskSaveResult.errorRows.size();

        return bulkTaskSaveResult;
    }

    public static List<Id> uploadAttachedFiles(List<File> files, List<Task> tasks) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (File file : files) {
            ContentVersion contentVersion = new ContentVersion();

            contentVersion.VersionData = EncodingUtil.base64Decode(file.base64Data);
            contentVersion.PathOnClient = file.fileName;
            contentVersion.Title = file.fileName;

            contentVersions.add(contentVersion);
        }

        insert contentVersions;

        Set<Id> contentVersionIds = new Set<Id>();
        for (ContentVersion contentVersion : contentVersions) {
            contentVersionIds.add(contentVersion.Id);
        }

        List<ContentVersion> contentVersionsUploaded = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id IN :contentVersionIds
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentVersion contentVersion : contentVersionsUploaded) {
            contentDocumentIds.add(contentVersion.ContentDocumentId);
        }

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for (Id contentDocumentId : contentDocumentIds) {
            for (Task task : tasks) {
                if (String.isBlank(task.Id)) {
                    continue;
                }

                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();

                contentDocumentLink.ContentDocumentId = contentDocumentId;
                contentDocumentLink.LinkedEntityId = task.Id;
                //contentDocumentLink.ShareType = 'V';

                contentDocumentLinks.add(contentDocumentLink);
            }
        }

        insert contentDocumentLinks;

        System.debug('contentDocumentIds: ' + contentDocumentIds);

        return contentDocumentIds;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPredefinedTasksFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        EUR_TR_Definition__c definition = (EUR_TR_Definition__c) JSON.deserialize(requestBody, EUR_TR_Definition__c.class);

        serviceResponse.Code = 1;
        serviceResponse.Data = getPredefinedTasks(definition);

        return serviceResponse;
    }

    @AuraEnabled
    public static List<EUR_TR_Definition__c> getPredefinedTasks(EUR_TR_Definition__c request) {
        if (String.isBlank(request.RecordType.DeveloperName)) {
            throw new BTIException('Kayıt tipi belirtmelisiniz.');
        }

        return [
                SELECT Id, EUR_TR_TaskDescription__c, EUR_TR_TaskType__c, Name, EUR_TR_ActivityDate__c,
                        RecordType.DeveloperName
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = :request.RecordType.DeveloperName
                AND EUR_TR_TaskType__c != 'Konum Bilgisi Güncelle'
        ];
    }

    public enum ImportTypes { fastTrack, preseller }

    public class BTIException extends Exception { }

    public class File {
        @AuraEnabled public String base64Data { get; set; }
        @AuraEnabled public String fileName { get; set; }
    }

    public class BulkTaskSaveResult {
        @AuraEnabled public Integer errorSize { get; set; }
        @AuraEnabled public Integer successSize { get; set; }
        @AuraEnabled public List<Integer> errorRows { get; set;}

        public BulkTaskSaveResult() {
            this.errorSize = 0;
            this.successSize = 0;
            this.errorRows = new List<Integer>();
        }
    }

    public class TaskWrapper {
        @AuraEnabled public String Cliente { get; set; }
        @AuraEnabled public String What_EUR_TR_AccountCode { get; set; }
        @AuraEnabled public String Description { get; set; }
        @AuraEnabled public String Username { get; set; }
        @AuraEnabled public Date ActivityDate { get; set; }
    }
}