public with sharing class EUR_CRM_TerritoryOwnerChanged extends EUR_CRM_TriggerAbstract {

    private static final String ACCOUNT_NG_ON_TRADE = 'EUR_NG_On_Trade';
    private static final Set<String> TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        'EUR_CRM_TerritoryOwnerChanged', 'TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE');
//    private final Set<String> TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE = new Set<String>{
//        'EUR_CRM_NG_Territory'
//    ,   'EUR_MA_Territory'
//    };

    public static final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        'EUR_CRM_TerritoryOwnerChanged', 'ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER');
//    public static final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER = new Set<String>{
//            'EUR_RU_On_Trade'
//        ,   'EUR_RU_Direct_Off_Trade'
//        ,   'EUR_RU_Indirect_Off_Trade'
//        ,   'EUR_RU_Direct_Type_2_Off_Trade'
//        ,   'EUR_RU_Distribution_Center'
//        ,   'EUR_RU_Distributor'
//    };

    public EUR_CRM_TerritoryOwnerChanged() {
        super('EUR_CRM_TerritoryOwnerChanged');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        System.debug('\n TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE.size() => ' + TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE.size() + '\n');
        System.debug('\n TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE => ' + JSON.serializePretty(TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE) + '\n');
        if (tAction == TriggerAction.BEFORE_UPDATE && !isBypassByCurrentUser()) {
            beforeUpdateAction(sObjList, newMap, oldMap);
        }
        if (tAction == TriggerAction.AFTER_UPDATE) {
            afterUpdateAction((List<EUR_CRM_Territory__c>)sObjList, (Map<Id, EUR_CRM_Territory__c>)newMap, (Map<Id, EUR_CRM_Territory__c>)oldMap);
        }
    }

    void beforeUpdateAction(List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<EUR_CRM_Territory__c> teryList = (List<EUR_CRM_Territory__c>) sObjList;
        Map<ID, EUR_CRM_Territory__c> oldTeryMap = (Map<ID, EUR_CRM_Territory__c>) oldMap;

        for (EUR_CRM_Territory__c tery : teryList) {
            if (tery.EUR_CRM_Territory_Owner__c != oldTeryMap.get(tery.id).EUR_CRM_Territory_Owner__c ||
                    tery.EUR_CRM_Off_Trade_Owner__c != oldTeryMap.get(tery.id).EUR_CRM_Off_Trade_Owner__c ||
                    tery.EUR_CRM_On_Trade_Owner__c != oldTeryMap.get(tery.id).EUR_CRM_On_Trade_Owner__c) {
                tery.EUR_CRM_IsOwnerChanged__c = true;
            }

            // IF TERRITORY is NG or MA
            // Owner can be from multiple sources, OFF Trade Owner, ON Trade Owner, or KD Owner (NG Only)
            if (TERRITORY_RT_TO_CHECK_KD_OWNER_CHANGE.contains(tery.EUR_CRM_RTDevName__c)) {
                if ((tery.EUR_CRM_KD_Owner__c != oldTeryMap.get(tery.id).EUR_CRM_KD_Owner__c) ||
                        (tery.EUR_CRM_Off_Trade_Owner__c != oldTeryMap.get(tery.id).EUR_CRM_Off_Trade_Owner__c) ||
                        (tery.EUR_CRM_On_Trade_Owner__c != oldTeryMap.get(tery.id).EUR_CRM_On_Trade_Owner__c)) {
                    tery.EUR_CRM_IsOwnerChanged__c = true;
                }
            }

        }
    }

    void afterUpdateAction(List<EUR_CRM_Territory__c> sObjList, Map<ID, EUR_CRM_Territory__c> newMap, Map<ID, EUR_CRM_Territory__c> oldMap) {
        Map<Id, EUR_CRM_Account__c> accountsToUpdate = new Map<Id, EUR_CRM_Account__c>();
        List<EUR_CRM_Territory__c> terrToProcess = new List<EUR_CRM_Territory__c>();
        List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();
        Set<Id> unShareUserIds = new Set<Id>();       
        for(EUR_CRM_Territory__c terr: (List<EUR_CRM_Territory__c>) sObjList){
            if(terr.EUR_CRM_IsOwnerChanged__c){
                terrToProcess.add(terr);
                unShareUserIds.add(oldMap.get(terr.Id).EUR_CRM_KD_Owner__c);
            }
        }

        if(!terrToProcess.isEmpty()){
            List<EUR_CRM_Account__c> accounts = [
                    SELECT Id
                        , OwnerId
                        , EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c
                        , EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.ManagerId
                        , EUR_CRM_Territory__r.EUR_CRM_KD_Owner__c
                        , EUR_CRM_RTDevName__c
                        , EUR_CRM_Image_Level_Name__c
                        , EUR_CRM_Territory__c
                        , EUR_CRM_Territory_KD_Owner__c
                        , RecordType.DeveloperName
                    FROM EUR_CRM_Account__c
                    WHERE EUR_CRM_Territory__c IN :terrToProcess
                    AND EUR_CRM_Territory__r.EUR_CRM_IsOwnerChanged__c = true
            ];
    
            if (accounts.size() < 100) {
                System.debug('\n Size Of Accounts List  accounts.size => ' + accounts.size() + '\n');
                unShareUserIds = new Set<Id>();
                for (EUR_CRM_Account__c account : accounts) {
                    if (account.EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c !=null) {
                        this.setAccountManager(account);
                        account.OwnerId = account.EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c;
                        accountsToUpdate.put(account.Id, account);
                    }
                    //share accounts for kd users
                    if(account.EUR_CRM_RTDevName__c == ACCOUNT_NG_ON_TRADE && String.isNotBlank(account.EUR_CRM_Image_Level_Name__c) && account.EUR_CRM_Image_Level_Name__c != 'Mainstream' &&
                            newMap.get(account.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c != oldMap.get(account.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c){
                        euAccounts.add(account);
                        unShareUserIds.add(oldMap.get(account.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c);
                    }
                }
                
                if(!accountsToUpdate.isEmpty()){

                    update accountsToUpdate.values();
                }

                if(!euAccounts.isEmpty()){
                    EUR_CRM_NG_ShareEUAccountHandler.populateAccountEUShare(euAccounts, unShareUserIds, false);
                }

            } else if (!System.isFuture() && !System.isBatch()) {
                System.debug('\n Size Of Accounts List  accounts.size => ' + accounts.size() + '\n');
                createMassUpdateBatch((new Map<Id, EUR_CRM_Territory__c>(terrToProcess)).keySet(), unShareUserIds);

            }
        }
    }

    private void setAccountManager(EUR_CRM_Account__c account) {
        if (ACCOUNT_RECORD_TYPES_TO_SET_MANAGER_OF_ACCOUNT_OWNER_DEPENDING_OWNER.contains(account.RecordType.DeveloperName)) {
            account.EUR_CRM_Manager_of_Account_Owner__c = account.EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__r.ManagerId;
        }
    }

    @TestVisible
    void createMassUpdateBatch(Set<Id> territoryIds, Set<Id> unShareUserIds){
        EUR_CRM_MassUpdateAccountOwner updateBatch = new EUR_CRM_MassUpdateAccountOwner(territoryIds, unShareUserIds);
        Database.executeBatch(updateBatch, 50);
    }
}