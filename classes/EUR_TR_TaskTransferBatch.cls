/**
 * Created by ali.kucuk@teknait.com on 9/10/2019.
 */

public with sharing class EUR_TR_TaskTransferBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    public enum RunModes {
        Cancel,
        Other
    }

    Datetime transferTime;
    String authorizationKey;
    RunModes runMode;
    public EUR_TR_TaskTransferBatch(RunModes runMode) {
        this.runMode = runMode;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        this.authorizationKey = authService.GetAuthorizationKey('TEKNA', '111111');
        this.transferTime = Datetime.now();

        if (this.runMode == RunModes.Cancel) {
            return Database.getQueryLocator([
                    SELECT PR_Activity_Type__c,WhatId,ActivityDate,Subject,Description,Status, CreatedDate, Cliente__c
                    FROM Task
                    WHERE PR_Activity_Type__c = 'Preseller'
                    AND PR_DateTime__c = NULL
                    AND Status = 'Canceled'
            ]);
        } else {
            return Database.getQueryLocator([
                    SELECT PR_Activity_Type__c,WhatId,ActivityDate,Subject,Description,Status, CreatedDate, Cliente__c
                    FROM Task
                    WHERE PR_Activity_Type__c = 'Preseller'
                    AND PR_DateTime__c = NULL
                    AND Status != 'Canceled'
            ]);
        }
    }
    public void execute(Database.BatchableContext context, List<Task> tasks) {
        System.debug('tasks.size() : ' + tasks.size());
        List<Id> accountIds = new List<Id>();
        List<Task> activeTasks = new List<Task>();
        List<Task> cancelledTasks = new List<Task>();
        Set<Id> ojtDayIds = new Set<Id>();

        for (Task task : tasks) {
            if (task.Cliente__c == 'OJT') {
                ojtDayIds.add(task.WhatId);
            } else {
                accountIds.add(task.WhatId);
            }

            if (task.Status == 'Canceled') {
                cancelledTasks.add(task);
            } else {
                activeTasks.add(task);
            }
        }

        List<EUR_TR_OJT__c> ojtVisits = [
                SELECT Id,
                        EUR_TR_RelatedDay__c,
                        EUR_TR_Account__r.Id,
                        EUR_TR_Account__r.EUR_TR_AccountCode__c,
                        EUR_TR_Account__r.EUR_TR_DistributorName__c
                FROM EUR_TR_OJT__c
                WHERE EUR_TR_RelatedDay__c IN :ojtDayIds
        ];

        Map<Id, List<EUR_TR_Account__c>> ojtAccountsByDayMap = new Map<Id, List<EUR_TR_Account__c>>();
        for (EUR_TR_OJT__c ojtVisit : ojtVisits) {
            if (ojtVisit.EUR_TR_Account__r == null) {
                continue;
            }

            if (ojtAccountsByDayMap.containsKey(ojtVisit.EUR_TR_RelatedDay__c)) {
                ojtAccountsByDayMap.get(ojtVisit.EUR_TR_RelatedDay__c).add(ojtVisit.EUR_TR_Account__r);
            } else {
                ojtAccountsByDayMap.put(ojtVisit.EUR_TR_RelatedDay__c, new List<EUR_TR_Account__c>{ojtVisit.EUR_TR_Account__r});
            }
        }

        List<EUR_TR_Account__c> accounts = [
                SELECT Id,Name,EUR_TR_PresellerName__c,EUR_TR_AccountCode__c, EUR_TR_DistributorName__c
                FROM EUR_TR_Account__c
                WHERE Id IN :accountIds
        ];
        System.debug('accounts.size() : ' + accounts.size());
        Map<Id, EUR_TR_Account__c> accountsMap = new Map<Id, EUR_TR_Account__c>();
        for (EUR_TR_Account__c account : accounts) {
            accountsMap.put(account.Id, account);
        }
        Map<String, String> distributorMap = new Map<String, String>();
        for (EUR_TR_Distributor__c d : [select Id, Name, EUR_TR_BranchId__c, EUR_TR_RegisteredName__c, EUR_TR_BranchCode__c from EUR_TR_Distributor__c]) {
            distributorMap.put(d.Name, d.EUR_TR_BranchCode__c);
        }

        if (activeTasks != null && activeTasks.size() > 0) {
            transferActiveTask(activeTasks, accountsMap, distributorMap, ojtAccountsByDayMap);
        }
        if (cancelledTasks != null && cancelledTasks.size() > 0) {
            transferCanceledTask(cancelledTasks, accountsMap, distributorMap, ojtAccountsByDayMap);
        }
    }

    void transferCanceledTask(List<Task> tasks, Map<Id, EUR_TR_Account__c> accountsMap, Map<String, String> distributorMap, Map<Id, List<EUR_TR_Account__c>> ojtAccountsByDayMap) {
        System.debug('In transferCanceledTask');
        System.debug('tasks : ' + tasks.size());
        String requestTemplate = '<Tasks>{Tasks}</Tasks>';
        String createDatetime = Datetime.now().format('dd.MM.yyyy H:mm:ss'); //Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss+03:00');

        String taskTemplate = '<Task><UniqueId>{UniqueId}</UniqueId><CreatedDatetime>{CreatedDatetime}</CreatedDatetime><Description>{Description}</Description><CompanyCode>PR</CompanyCode><BranchCode/><CustomerCode>{CustomerCode}</CustomerCode><CancelReason>TDIGG</CancelReason></Task>';
        String tasksString = '';
        for (Task task : tasks) {
            String uniqueId = String.valueOf(Datetime.now().millisecondGmt());
            List<EUR_TR_Account__c> accounts = new List<EUR_TR_Account__c>();

            if (task.Cliente__c == 'OJT') {
                accounts = ojtAccountsByDayMap.get(task.WhatId);
            } else {
                EUR_TR_Account__c account = accountsMap.get(task.WhatId);
                if (account == null) {
                    continue;
                }

                accounts = new List<EUR_TR_Account__c>{account}; // 1 account in for loop
            }

            if (accounts.isEmpty()) {
                continue;
            }

            for (EUR_TR_Account__c account : accounts) {
                String description = String.format('{0} - {1}', new List<String>{
                        'Görev Tipi: ' + task.Cliente__c,
                        'Görev Açıklaması: ' + task.Description
                });
                String customerCode = account.EUR_TR_AccountCode__c;
                String relatedBranch = distributorMap.get(account.EUR_TR_DistributorName__c);
                String taskString = taskTemplate.replace('{UniqueId}', uniqueId)
                        .replace('{CreatedDatetime}', createDatetime)
                        .replace('{Description}', description)
                        .replace('{CustomerCode}', customerCode)
                        .replace('{BranchId}', relatedBranch);
                tasksString += taskString;
            }
        }

        String requestBody = requestTemplate.replace('{Tasks}', tasksString);
        System.debug(requestBody);

        if (tasks != null && tasks.size() > 0) {
            doIntegration(requestBody, tasks, 500);
        }
    }

    void transferActiveTask(List<Task> tasks, Map<Id, EUR_TR_Account__c> accountsMap, Map<String, String> distributorMap, Map<Id, List<EUR_TR_Account__c>> ojtAccountsByDayMap) {
        System.debug('In transferActiveTask');
        System.debug('tasks : ' + tasks.size());
        String requestTemplate = '<Tasks>{Tasks}</Tasks>';
        String createDatetime = Datetime.now().format('dd.MM.yyyy H:mm:ss'); //.format('yyyy-MM-dd\'T\'HH:mm:ss+03:00');

        String taskTemplate = '<Task><UniqueId>{UniqueId}</UniqueId><CreatedDatetime>{CreatedDatetime}</CreatedDatetime><Description>{Description}</Description><CompanyCode>PR</CompanyCode><BranchCode/><CustomerCode>{CustomerCode}</CustomerCode><RouteType/><StartDate>{StartDate}</StartDate><EndDate>{EndDate}</EndDate><Notes><Note>{Note}</Note></Notes></Task>';
        String tasksString = '';
        for (Task task : tasks) {
            String uniqueId = String.valueOf(Datetime.now().millisecondGmt());
            List<EUR_TR_Account__c> accounts;

            if (task.Cliente__c == 'OJT') {
                accounts = ojtAccountsByDayMap.get(task.WhatId);
            } else {
                accounts = new List<EUR_TR_Account__c>{accountsMap.get(task.WhatId)}; // 1 account in for loop
            }

            if (accounts == null || accounts.isEmpty()) {
                continue;
            }

            for (EUR_TR_Account__c account : accounts) {
                String description = String.format('{0} - {1}', new List<String>{
                        'Görev Tipi: ' + task.Cliente__c,
                        'Görev Açıklaması: ' + task.Description
                });
                String customerCode = account.EUR_TR_AccountCode__c;
                String startDate = Datetime.newInstance(task.CreatedDate.year(), task.CreatedDate.month(), task.CreatedDate.day()).format('yyyy-MM-dd');
                String endDate = Datetime.newInstance(task.ActivityDate.year(), task.ActivityDate.month(), task.ActivityDate.day()).format('yyyy-MM-dd');
                String note = task.Description;
                String relatedBranch = distributorMap.get(account.EUR_TR_DistributorName__c);
                String taskString = taskTemplate.replace('{UniqueId}', uniqueId)
                        .replace('{CreatedDatetime}', createDatetime)
                        .replace('{Description}', description)
                        .replace('{CustomerCode}', customerCode)
                        .replace('{StartDate}', startDate)
                        .replace('{EndDate}', endDate)
                        .replace('{Note}', note)
                        .replace('{BranchId}', relatedBranch) ;
                tasksString += taskString;
            }
        }

        String requestBody = requestTemplate.replace('{Tasks}', tasksString);
        System.debug('request:' + requestBody);

        if (tasks != null && tasks.size() > 0) {
            doIntegration(requestBody, tasks, 500);
        }
    }

    void doIntegration(String requestBody, List<Task> tasks, Integer method) {
        System.debug('In doIntegration');
        try {
            EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
            String encodedString = EncodingUtil.base64Encode(Blob.valueOf(requestBody));
            System.debug(encodedString);
            EUR_TR_Service_Customer.Result taskIntegrationResponse = customerService.TaskIntegration(encodedString, this.authorizationKey, method);

            String errorMessage = trimTaskTransferErrorMessage(taskIntegrationResponse.Message);
            for (Task task : tasks) {
                task.PR_DateTime__c = taskIntegrationResponse.isCompleted == true ? transferTime : null;
                task.PR_Memo__c = taskIntegrationResponse.isCompleted == true ? null : errorMessage;
            }
            System.debug('response.Message:' + taskIntegrationResponse.Message);
            System.debug('response.isCompleted:' + taskIntegrationResponse.isCompleted);
            System.debug('response.StackTrace:' + taskIntegrationResponse.StackTrace);
            update tasks;
        } catch (Exception ex) {
            System.debug('Error : ' + ex.getMessage());
            System.debug('Error : ' + ex.getStackTraceString());
            String errorMessage = trimTaskTransferErrorMessage(ex.getMessage());
            for (Task task : tasks) {
                //task.EUR_TR_TaskTransferTime__c = null;
                task.PR_Memo__c = errorMessage;
            }
            update tasks;
            throw ex;
        }
    }

    String trimTaskTransferErrorMessage(String message) {
        if (message != null && message.length() > 255) {
            message = message.substring(0, 255);
        }
        return message;
    }

    public void finish(Database.BatchableContext context) {
    }
}