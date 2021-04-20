/**
*   Class: EUR_CRM_MassUpdateMAAccountOwner
*   Description: Apex Batch Job Class to update the owner and sharing access of the account related to the territories
*/
global class EUR_CRM_MassUpdateMAAccountOwner implements Database.Batchable<sObject>, Database.Stateful{
    private final String MA_DISTRIBUTOR = 'EUR_MA_Distributor';
    private final String MA_ON_TRADE = 'EUR_MA_On_Trade';
    private final String MA_OFF_TRADE = 'EUR_MA_Off_Trade';    
    
    private final Map<String, String> mapRTDevNameToOwnerField = new Map<String, String>{
        MA_DISTRIBUTOR => 'EUR_CRM_Off_Trade_Owner__c',
        MA_ON_TRADE => 'EUR_CRM_On_Trade_Owner__c',
        MA_OFF_TRADE => 'EUR_CRM_Off_Trade_Owner__c'
    };

    global final String query;
    
    // Checking if user or role exist in the sharing of account. Key is made as ParentID + UserORGroupID
    // For custom object EU Account
    global Set<String> sharingAccountEUKeys;

    // Checking if user or role exist in the sharing of account. Key is made as ParentID + UserORGroupID
    // For Standard Account
    global Set<String> sharingAccountStdKeys;
    
    global EUR_CRM_MassUpdateMAAccountOwner(String q) {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    // Main Logic Implementation
    global void execute(Database.Batchablecontext BC, List<sObject> scope) {
        List<EUR_CRM_Account__c> acctList = (List<EUR_CRM_Account__c>)scope;
        List<EUR_CRM_Account__c> acctToUpdateList = new List<EUR_CRM_Account__c>();
        
        Set<Id> territoryIDSet = new Set<Id>();
        Map<Id, Id> accountTerritoryShare = new Map<Id, Id>();
        Map<Id, RecordType> accountRecordTypesMap = new Map<Id, RecordType>();

        List<EUR_CRM_Account__Share> euAcctShareList = new List<EUR_CRM_Account__Share>();
        List<AccountShare> stdAcctShareList = new List<AccountShare>();
        
        Set<ID> userIds = new Set<ID>();

        System.debug(acctList);
        for (EUR_CRM_Account__c acct: acctList) {
            String rtDevName = acct.RecordType.DeveloperName;//accountRecordTypesMap.get(acct.RecordTypeId).DeveloperName;
            System.debug(rtDevName);

            if(acct.EUR_CRM_Territory__c != null && mapRTDevNameToOwnerField.containsKey(rtDevName) 
                    && acct.EUR_CRM_Territory__r.get(mapRTDevNameToOwnerField.get(rtDevName))!=null){
                Id selOwnerId = (Id)acct.EUR_CRM_Territory__r.get(mapRTDevNameToOwnerField.get(rtDevName));
                acct.OwnerId = selOwnerId;
                territoryIDSet.add(acct.EUR_CRM_Territory__c);
                userIds.add(selOwnerId);
                acctToUpdateList.add(acct);
            }            
        }
        
        System.debug(acctToUpdateList);
        if (acctToUpdateList.size() > 0){
            update acctToUpdateList;
        }
        
        List<EUR_CRM_Territory__c> territoriesToUpdate = [SELECT Id, Name, EUR_CRM_IsOwnerChanged__c FROM EUR_CRM_Territory__c WHERE Id IN :territoryIDSet];
        System.debug(territoriesToUpdate);
        for(EUR_CRM_Territory__c i: territoriesToUpdate) {
            i.EUR_CRM_IsOwnerChanged__c = false;
        }
        
        if(territoriesToUpdate.size() > 0) {
            update territoriesToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob apexJob = [SELECT Id FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), apexJob.Id, new String[]{});
    }
}