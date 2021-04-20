global class EUR_CRM_MassUpdateAccountOwner implements Database.Batchable<sObject>, Database.Stateful {

    private static final String EUACCOUNT_NG_ON_TRADE = 'EUR_NG_On_Trade';
    private static final String IMAGELEVELMAINSTREAM = 'Mainstream';
    private static final String QUERYEUACCOUNT = 'SELECT Id' +
        ', OwnerId, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c, EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.ManagerId' +
        ', EUR_CRM_RTDevName__c, EUR_CRM_Image_Level_Name__c, EUR_CRM_Territory_KD_Owner__c, RecordType.DeveloperName ' +
        'FROM EUR_CRM_Account__c' +
        ' WHERE EUR_CRM_Territory__c IN :territoriesIds' +
        ' AND EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c = true';
    global final String query;
    private Set<ID> territoriesIds = new Set<Id>();
    private Set<Id> unShareUserIds = new Set<Id>();
    private Boolean doPostProcessing;

    global EUR_CRM_MassUpdateAccountOwner(Set<ID> territoriesIds) {
        this.territoriesIds = territoriesIds;
        query = QUERYEUACCOUNT;
    }

    global EUR_CRM_MassUpdateAccountOwner(Set<ID> territoriesIds, Set<Id> unShareUserIds) {
        this.unShareUserIds = unShareUserIds;
        this.territoriesIds = territoriesIds;
        query = QUERYEUACCOUNT;
    }    

    global EUR_CRM_MassUpdateAccountOwner(String q) {
        query = q;
        doPostProcessing = true;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    //Main Logic Implementation
    global void execute(Database.Batchablecontext BC, List<sObject> scope) {
        List<EUR_CRM_Account__c> acctList = (List<EUR_CRM_Account__c>) scope;
        List<EUR_CRM_Account__c> acctToUpdateList = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> euAccountsShare = new List<EUR_CRM_Account__c>();
        Set<ID> territoryIDSet = new Set<ID>();

        for (EUR_CRM_Account__c acct : acctList) {
            Boolean isChanged = false;
            if (acct.EUR_CRM_Territory__r != null) {
                if (acct.EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c != null) {
                    this.setAccountManager(acct);
                    acct.OwnerID = acct.EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c;
                    isChanged = true;
                }
            }
            Boolean isPrestige = false;
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(acct));
            isPrestige = m.get('EUR_CRM_Prestige_Territory__c') != null;
            if (isPrestige) {
                acct.EUR_CRM_Prestige_Sales_Rep__c = acct.EUR_CRM_Prestige_Territory__r.EUR_CRM_Territory_Owner__r.Name;
                acct.EUR_CRM_Prestige_Sales_Rep_ID__c = acct.EUR_CRM_Prestige_Territory__r.EUR_CRM_Territory_Owner__r.Id;
                territoryIDSet.add(acct.EUR_CRM_Prestige_Territory__c);
                isChanged = true;
            }
            //share accounts for kd owners
            if(m.get('EUR_CRM_RTDevName__c') != null && m.get('EUR_CRM_Image_Level_Name__c') != null) {
                if(acct.EUR_CRM_RTDevName__c == EUACCOUNT_NG_ON_TRADE &&
                        String.isNotBlank(acct.EUR_CRM_Image_Level_Name__c) &&
                        acct.EUR_CRM_Image_Level_Name__c != IMAGELEVELMAINSTREAM &&
                        acct.EUR_CRM_Territory__c != null){
                    euAccountsShare.add(acct);
                }
            }
            if (isChanged) {
                acctToUpdateList.add(acct);
            }
            territoryIDSet.add(acct.EUR_CRM_Territory__c);
        }

        if (acctToUpdateList.size() > 0){
            List<Database.SaveResult> srs = Database.update(acctToUpdateList, false);
            System.debug('contactsForUpdate Results: ' + srs);
        }

        if(!euAccountsShare.isEmpty()){
            EUR_CRM_NG_ShareEUAccountHandler.populateAccountEUShare(euAccountsShare, unShareUserIds, false);
        }

        territoryIDSet.remove(null);
        if (!territoryIDSet.isEmpty()) {
            List<EUR_CRM_Territory__c> territoriesToUpdate = new List<EUR_CRM_Territory__c>();
            for (Id tId: territoryIDSet){
                territoriesToUpdate.add(new EUR_CRM_Territory__c(Id=tId, EUR_CRM_IsOwnerChanged__c=false));
            }

            if(!territoriesToUpdate.isEmpty()){
                List<Database.SaveResult> srs = Database.update(territoriesToUpdate, false);
                System.debug('contactsForUpdate Results: ' + srs);
            }
        }

    }

    // Send email, clean and end execution
    global void finish(Database.BatchableContext BC) {
        if (doPostProcessing == true) {
            //AsyncApexJob apexjob = [Select Id From AsyncApexJob WHERE Id = :BC.getJobId()];
            EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[]{});
        }
    }

    private void setAccountManager(EUR_CRM_Account__c acct) {
        if (EUR_CRM_TerritoryOwnerChanged.ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER.contains(acct.RecordType.DeveloperName)) {
            acct.EUR_CRM_Manager_of_Account_Owner__c = acct.EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.ManagerId;
        }
    }

}