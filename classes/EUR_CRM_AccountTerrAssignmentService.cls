public with sharing class EUR_CRM_AccountTerrAssignmentService {

    private static final String CURRENT_CLASS_NAME = EUR_CRM_AccountTerrAssignmentService.class.getName();

    private final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME,'ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER');
//    private final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER = validRTbyVariableName.get('ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER');
//    private final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER = new Set<String> {
//        'EUR_CZ_ON_STD', 'EUR_CZ_ON_STD_LOCKED'
//    ,   'EUR_CZ_ON_VO', 'EUR_CZ_ON_VO_LOCKED'
//    ,   'EUR_CZ_ON_CAT', 'EUR_CZ_ON_CAT_LOCKED'
//    ,   'EUR_CZ_OFF_STD', 'EUR_CZ_OFF_STD_LOCKED'
//    ,   'EUR_CZ_OFF_VO', 'EUR_CZ_OFF_VO_LOCKED'
//
//    ,   'EUR_SK_ON_STD', 'EUR_SK_ON_STD_LOCKED'
//    ,   'EUR_SK_ON_VO', 'EUR_SK_ON_VO_LOCKED'
//    ,   'EUR_SK_ON_CAT', 'EUR_SK_ON_CAT_LOCKED'
//    ,   'EUR_SK_OFF_STD', 'EUR_SK_OFF_STD_LOCKED'
//    ,   'EUR_SK_OFF_VO', 'EUR_SK_OFF_VO_LOCKED'
//
//    ,   'EUR_GB_FS_Indirect'
//
//    ,   'EUR_DE_OFF_STD'
//    ,   'EUR_DE_ON_Consumers'
//    ,   'EUR_DE_ON_Enquiry_Acquisition'
//    ,   'EUR_DE_ON_Gastronomy'
//    ,   'EUR_DE_ON_Service_agency'
//    ,   'EUR_DE_ON_Wholesaler'
//
//    ,   'EUR_EE_DIR_ON_Trade', 'EUR_EE_DIR_OFF_Trade'
//    ,   'EUR_EE_INDIR_ON_Trade', 'EUR_EE_INDIR_OFF_Trade'
//
//    ,   'EUR_LV_DIR_ON_Trade', 'EUR_LV_DIR_OFF_Trade'
//    ,   'EUR_LV_INDIR_ON_Trade', 'EUR_LV_INDIR_OFF_Trade'
//    ,   'EUR_LV_DIR_OFF_Trade_w_CPT'
//
//    ,   'EUR_LT_DIR_ON_Trade', 'EUR_LT_DIR_OFF_Trade'
//    ,   'EUR_LT_INDIR_ON_Trade', 'EUR_LT_INDIR_OFF_Trade'
//    ,   'EUR_LT_DIR_OFF_Trade_w_CPT'
//
//    ,   'EUR_AO_On_Trade', 'EUR_AO_Off_Trade'
//
//    ,   'EUR_KE_On_Trade', 'EUR_KE_Off_Trade'
//    };

    private final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME,'ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY');
//    private final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY = validRTbyVariableName.get('ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY');
//    private final Set<String> ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY = new Set<String> {
//        'EUR_GB_Indies'
//    ,   'EUR_GB_FS_Blitz'
//    ,   'EUR_GB_FS_Indirect'
//
//    ,   'EUR_FI_Direct_On_Trade', 'EUR_FI_Direct_Off_Trade'
//    ,   'EUR_FI_Indirect_On_Trade', 'EUR_FI_Indirect_Off_Trade'
//
//    ,   'EUR_SE_On_Trade', 'EUR_SE_Off_Trade', 'EUR_SE_Wholesaler'
//
//    ,   'EUR_NL_On_Trade'
//    ,   'EUR_NL_Off_Trade'
//    ,   'EUR_NL_Wholesaler'
//    ,   'EUR_NL_Off_Trade_Independent'
//    ,   'EUR_NL_Off_Trade_Chains'
//
//    ,   'EUR_EE_DIR_OFF_Trade'
//    ,   'EUR_EE_DIR_ON_Trade'
//    ,   'EUR_EE_INDIR_OFF_Trade'
//    ,   'EUR_EE_INDIR_ON_Trade'
//
//    ,   'EUR_LT_DIR_OFF_Trade'
//    ,   'EUR_LT_DIR_ON_Trade'
//    ,   'EUR_LT_INDIR_OFF_Trade'
//    ,   'EUR_LT_INDIR_ON_Trade'
//
//    ,   'EUR_LV_DIR_OFF_Trade'
//    ,   'EUR_LV_DIR_ON_Trade'
//    ,   'EUR_LV_INDIR_OFF_Trade'
//    ,   'EUR_LV_INDIR_ON_Trade'
//
//    ,   'EUR_RU_On_Trade'
//    ,   'EUR_RU_Direct_Off_Trade', 'EUR_RU_Indirect_Off_Trade'
//    ,   'EUR_RU_Direct_Type_2_Off_Trade'
//    ,   'EUR_RU_Distribution_Center'
//    ,   'EUR_RU_Distributor'
//
//    ,   'EUR_MA_On_Trade', 'EUR_MA_Off_Trade'
//    ,   'EUR_MA_Distributor'
//
//    ,   'EUR_CH_ON_B2B'
//    ,   'EUR_CH_ON_Cash_Carry'
//    ,   'EUR_CH_ON_HORECA'
//    ,   'EUR_CH_ON_Hotel'
//    ,   'EUR_CH_ON_Wholesaler'
//
//    ,   'EUR_DE_Off_Trade_New_Business'
//    ,   'EUR_DE_Off_Trade_Retail'
//    ,   'EUR_DE_On_Trade_B2B'
//    ,   'EUR_DE_On_Trade_Gastronomy'
//    ,   'EUR_DE_On_Trade_Hotel'
//    ,   'EUR_DE_On_Trade_New_Business'
//    ,   'EUR_DE_On_Trade_Special_Stores'
//    ,   'EUR_DE_On_Trade_System_Gastronomy'
//    ,   'EUR_DE_On_Trade_Wholesaler'
//
//    ,   'EUR_DK_On_Trade', 'EUR_DK_OFF_Trade'
//    ,   'EUR_DK_Wholesaler'
//
//    ,   'EUR_BG_On_Trade'
//    ,   'EUR_BG_Modern_Off_Trade'
//    ,   'EUR_BG_Traditional_Off_Trade'
//    ,   'EUR_BG_Wholesaler'
//
//    ,   'EUR_PT_On_Trade', 'EUR_PT_Off_Trade'
//    ,   'EUR_PT_Wholesaler'
//    ,   'EUR_PT_CandCs'
//
//    ,   'EUR_BE_On_Trade', 'EUR_BE_Off_Trade'
//    ,   'EUR_BE_Wholesaler'
//    ,   'EUR_BE_B2B'
//
//    ,   'EUR_NG_On_Trade'
//    ,   'EUR_NG_Off_Trade_Traditional'
//    ,   'EUR_NG_Off_Trade_Bulk_Breaker'
//
//    ,   'EUR_AO_On_Trade', 'EUR_AO_Off_Trade'
//    ,   'EUR_KE_On_Trade', 'EUR_KE_Off_Trade'
//
//    ,   'EUR_DB_Wholesaler_Account'
//    ,   'EUR_DB_On_Trade_Account', 'EUR_DB_Off_Trade_Account'
//    ,   'EUR_IDL_Wholesaler_Account'
//    ,   'EUR_IDL_On_Trade_Account', 'EUR_IDL_Off_Trade_Account'
//    ,   'EUR_IT_Off_Trade_Account', 'EUR_IT_On_Trade_Account'
//    ,   'EUR_IT_Wholesaler_Account', 'EUR_IT_Enoteca_Account'
//
//    ,   'EUR_AT_ON_Cash_Carry'
//    ,   'EUR_AT_ON_Gastronomy'
//    ,   'EUR_AT_ON_Hotel'
//    ,   'EUR_AT_ON_System_Gastronomy'
//    ,   'EUR_AT_On_Trade'
//    ,   'EUR_AT_ON_Wholesaler'
//    };

    private final Set<String> ACCOUNT_AO_KE_RECORD_TYPES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME,'ACCOUNT_AO_KE_RECORD_TYPES');
//    private final Set<String> ACCOUNT_AO_KE_RECORD_TYPES = validRTbyVariableName.get('ACCOUNT_AO_KE_RECORD_TYPES');
//    private final Set<String> ACCOUNT_AO_KE_RECORD_TYPES = new Set<String>{
//        'EUR_AO_On_Trade', 'EUR_AO_Off_Trade'
//    ,   'EUR_KE_On_Trade', 'EUR_KE_Off_Trade'
//    };

    private final Set<String> TERRITORY_AO_KE_RECORD_TYPES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME,'TERRITORY_AO_KE_RECORD_TYPES');
//    private final Set<String> TERRITORY_AO_KE_RECORD_TYPES = validRTbyVariableName.get('TERRITORY_AO_KE_RECORD_TYPES');
//    private final Set<String> TERRITORY_AO_KE_RECORD_TYPES = new Set<String>{
//        'EUR_AO_Territory'
//    ,   'EUR_KE_Territory'
//    };

    private final Set<String> ACCOUNT_NG_OFF_TRADE_RECORD_TYPES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
        CURRENT_CLASS_NAME,'ACCOUNT_NG_OFF_TRADE_RECORD_TYPES');
//    private final Set<String> ACCOUNT_NG_OFF_TRADE_RECORD_TYPES = validRTbyVariableName.get('ACCOUNT_NG_OFF_TRADE_RECORD_TYPES');
//    private final Set<String> ACCOUNT_NG_OFF_TRADE_RECORD_TYPES = new Set<String>{
//        'EUR_NG_Off_Trade_Traditional', 'EUR_NG_Off_Trade_Bulk_Breaker'
//    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void onBeforeInsert(List<EUR_CRM_Account__c> accounts) {
        Map<Id, String> rtDevNameByRTId = this.getRTDeveloperNameByRTId(accounts);
        System.debug('\n\n rtDevNameByRTId => ' + JSON.serializePretty(rtDevNameByRTId) + '\n');

        Map<Id, List<EUR_CRM_Account__c>> accountsWithoutTerritoryByOwnerId = this.getAccountsWithoutTerritoryByOwnerId(accounts, rtDevNameByRTId);
        System.debug('\n\n accountsWithoutTerritoryByOwnerId => ' + JSON.serializePretty(accountsWithoutTerritoryByOwnerId) + '\n');

        Map<Id, List<EUR_CRM_Account__c>> accountsWithTerritoryByTerritoryId = this.getAccountsWithTerritoryByTerritoryId(accounts, rtDevNameByRTId);
        System.debug('\n\n accountsWithTerritoryByTerritoryId => ' + JSON.serializePretty(accountsWithTerritoryByTerritoryId) + '\n');

        if (accountsWithoutTerritoryByOwnerId.isEmpty() && accountsWithTerritoryByTerritoryId.isEmpty()) { return ; }

        List<EUR_CRM_Territory__c> territories = this.selectTerritory(accountsWithTerritoryByTerritoryId.keySet(), accountsWithoutTerritoryByOwnerId.keySet());

        if( ! accountsWithoutTerritoryByOwnerId.isEmpty()) {
            this.setTerritoryDependingOnAccountOwner(accountsWithoutTerritoryByOwnerId, territories, rtDevNameByRTId);
        }

        if( ! accountsWithTerritoryByTerritoryId.isEmpty()) {
            this.setAccountOwnerDependingOnTerritory(accountsWithTerritoryByTerritoryId, territories, rtDevNameByRTId);
        }
    }

    public void onBeforeUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accountsWithChangedTerritoryOrImageLevelByTerritoryId = this.getAccountsWithChangedTerritoryOrImageLevel(accounts, oldAccountById);
        System.debug('\n\n accountsWithChangedTerritoryByTerritoryId => ' + JSON.serializePretty(accountsWithChangedTerritoryOrImageLevelByTerritoryId) + '\n');
        if (accountsWithChangedTerritoryOrImageLevelByTerritoryId.isEmpty()) { return ; }

        this.updateAccountOwnerDependingOnTerritory(accountsWithChangedTerritoryOrImageLevelByTerritoryId);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void setTerritoryDependingOnAccountOwner(Map<Id, List<EUR_CRM_Account__c>> accountsByOwnerId, List<EUR_CRM_Territory__c> territories, Map<Id, String> rtDevNameByRTId) {
        Map<Id, List<EUR_CRM_Territory__c>> territoryIdByOwnerId = this.getTerritoriesByOwnerId(territories);
        System.debug('\n\n territoryIdByOwnerId => ' + JSON.serializePretty(territoryIdByOwnerId) + '\n');
        if (territoryIdByOwnerId.isEmpty()) { return ; }

        for (Id ownerId : accountsByOwnerId.keySet()) {
            for (EUR_CRM_Account__c account : accountsByOwnerId.get(ownerId)) {
                if (territoryIdByOwnerId.containsKey(ownerId)) {
                    String accRTDevName = rtDevNameByRTId.get(account.RecordTypeId);
                    if (ACCOUNT_AO_KE_RECORD_TYPES.contains(accRTDevName)) {

                        for (EUR_CRM_Territory__c territory : territoryIdByOwnerId.get(ownerId)) {
                            String terrRtDevName = territory.RecordType.DeveloperName;
                            if (TERRITORY_AO_KE_RECORD_TYPES.contains(terrRtDevName) && accRTDevName.substring(0, 6).equalsIgnoreCase(terrRtDevName.substring(0, 6)) && account.EUR_CRM_Channel__c == territory.EUR_CRM_Territory_Channel__c && territory.EUR_CRM_Default__c == true) {
                                account.EUR_CRM_Territory__c = territory.Id;
                            }
                        }
                    } else {
                        List<EUR_CRM_Territory__c> terrs = territoryIdByOwnerId.get(ownerId);
                        if( ! terrs.isEmpty()) {
                            account.EUR_CRM_Territory__c = terrs[terrs.size() - 1].Id;
                        }
                    }
                    System.debug('\n\n account.EUR_CRM_Territory__c => ' + JSON.serializePretty(account.EUR_CRM_Territory__c) + '\n');
                }
            }
        }
    }

    private void setAccountOwnerDependingOnTerritory(Map<Id, List<EUR_CRM_Account__c>> accountsByTerritoryId, List<EUR_CRM_Territory__c> territories, Map<Id, String> rtDevNameByRTId) {
        Map<Id, EUR_CRM_Territory__c> territoryById = new Map<Id, EUR_CRM_Territory__c>(territories);
        System.debug('\n\n territoryById => ' + JSON.serializePretty(territoryById) + '\n');

        this.doUpdateAccountOwnerDependingOnTerritory(accountsByTerritoryId, territoryById, rtDevNameByRTId);
    }

    private void updateAccountOwnerDependingOnTerritory(List<EUR_CRM_Account__c> accounts) {
        Map<Id, String> rtDevNameByRTId = this.getRTDeveloperNameByRTId(accounts);
        System.debug('\n\n rtDevNameByRTId => ' + JSON.serializePretty(rtDevNameByRTId) + '\n');

        List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();

        for (EUR_CRM_Account__c account : accounts) {
            if (ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY.contains(rtDevNameByRTId.get(account.RecordTypeId))) {
                accountsToUpdate.add(account);
            }
        }
        if (accountsToUpdate.isEmpty()) { return ; }

        Map<Id, List<EUR_CRM_Account__c>> accountsByTerritoryId = this.configureAccountsByTerritoryId(accountsToUpdate);

        Map<Id, EUR_CRM_Territory__c> territoryById = this.selectTerritoryById(accountsByTerritoryId.keySet());

        this.doUpdateAccountOwnerDependingOnTerritory(accountsByTerritoryId, territoryById, rtDevNameByRTId);
    }

    private void doUpdateAccountOwnerDependingOnTerritory(Map<Id, List<EUR_CRM_Account__c>> accountsByTerritoryId, Map<Id, EUR_CRM_Territory__c> territoryById,  Map<Id, String> rtDevNameByRTId) {
        Map<Id, List<EUR_CRM_Account__c>> accountsByTerritoryIdToUpdate = new Map<Id, List<EUR_CRM_Account__c>>();

        for (Id terrId : accountsByTerritoryId.keySet()) {
            for (EUR_CRM_Account__c account : accountsByTerritoryId.get(terrId)) {
                if (territoryById.containsKey(terrId)) {
                    EUR_CRM_Territory__c territory = territoryById.get(terrId);
//                    if (account.EUR_CRM_Country_Code__c == 'MA') {
//                        String rtDevName = rtDevNameByRTId.get(account.RecordTypeId);
//                        if (rtDevName.equalsIgnoreCase('EUR_MA_On_Trade')) {
//                            account.OwnerId = territory.EUR_CRM_On_Trade_Owner__c != null ? territory.EUR_CRM_On_Trade_Owner__c : account.OwnerId;
//                        } else if (rtDevName.equalsIgnoreCase('EUR_MA_Off_Trade') || rtDevName.equalsIgnoreCase('EUR_MA_Distributor')) {
//                            account.OwnerId = territory.EUR_CRM_Off_Trade_Owner__c != null ? territory.EUR_CRM_Off_Trade_Owner__c : account.OwnerId;
//                        }
//                    } else {
                    String rtDevName = rtDevNameByRTId.get(account.RecordTypeId);
                    /*if (rtDevName == 'EUR_NG_On_Trade') {
                        if (accountsByTerritoryIdToUpdate.containsKey(terrId)) {
                            accountsByTerritoryIdToUpdate.get(terrId).add(account);
                        } else {
                            accountsByTerritoryIdToUpdate.put(terrId, new List<EUR_CRM_Account__c>{ account });
                        }
                    } else */
                    if (ACCOUNT_NG_OFF_TRADE_RECORD_TYPES.contains(rtDevName)) {
                        account.OwnerId = territory.EUR_CRM_KD_Owner__c;
                    } else {
                        if (territory.EUR_CRM_Territory_Owner__c != null) {
                            account.OwnerId = territory.EUR_CRM_Territory_Owner__c;
                        }
                    }
//                    }
                }
            }
        }

        System.debug('\n\n accountsByTerritoryIdToUpdate => ' + JSON.serializePretty(accountsByTerritoryIdToUpdate) + '\n');
        if( ! accountsByTerritoryIdToUpdate.isEmpty()) {
            this.updateAccountOwnerDependingOnImageLevel(accountsByTerritoryIdToUpdate, territoryById);
        }
    }

    private void updateAccountOwnerDependingOnImageLevel(Map<Id, List<EUR_CRM_Account__c>> accountsByTerritoryId, Map<Id, EUR_CRM_Territory__c> territoryById) {
        Map<Id, EUR_CRM_PRS_Seg_Aspect__c> imageLevelById = this.selectImageLevelById(this.extractImageLevelIds(accountsByTerritoryId));
        System.debug('\n\n imageLevelById => ' + JSON.serializePretty(imageLevelById) + '\n');

        for (Id terrId : accountsByTerritoryId.keySet()) {
            if (territoryById.containsKey(terrId)) {
                for (EUR_CRM_Account__c account : accountsByTerritoryId.get(terrId)) {
                    if (imageLevelById.containsKey(account.EUR_CRM_PRS_Image_Level__c)
                        && imageLevelById.get(account.EUR_CRM_PRS_Image_Level__c).EUR_CRM_Segmentation_IL_Aspect_Name__c== 'Mainstream') {
                        account.OwnerId = territoryById.get(account.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c;
                    } else {
                        account.OwnerId = territoryById.get(account.EUR_CRM_Territory__c).EUR_CRM_On_Trade_Owner__c;
                    }
                }
            }
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_Account__c>> getAccountsWithoutTerritoryByOwnerId(List<EUR_CRM_Account__c> accounts, Map<Id, String> rtDevNameByRTId) {
        Map<Id, List<EUR_CRM_Account__c>> accountsWithoutTerritoryByOwnerId = new Map<Id, List<EUR_CRM_Account__c>>();
        for (EUR_CRM_Account__c account : accounts) {
            if (this.isNeedToPopulateTerritory(account, rtDevNameByRTId)) {
                if (accountsWithoutTerritoryByOwnerId.containsKey(account.OwnerId)) {
                    accountsWithoutTerritoryByOwnerId.get(account.OwnerId).add(account);
                } else {
                    accountsWithoutTerritoryByOwnerId.put(account.OwnerId, new List<EUR_CRM_Account__c> { account });
                }
            }
        }
        return accountsWithoutTerritoryByOwnerId;
    }

    private Map<Id, List<EUR_CRM_Account__c>> getAccountsWithTerritoryByTerritoryId(List<EUR_CRM_Account__c> accounts, Map<Id, String> rtDevNameByRTId) {
        Map<Id, List<EUR_CRM_Account__c>> accountsWithTerritoryByTerritoryId = new Map<Id, List<EUR_CRM_Account__c>>();
        for (EUR_CRM_Account__c account : accounts) {
            if (this.isNeedToUpdateAccountOwner(account, rtDevNameByRTId)) {
                if (accountsWithTerritoryByTerritoryId.containsKey(account.EUR_CRM_Territory__c)) {
                    accountsWithTerritoryByTerritoryId.get(account.EUR_CRM_Territory__c).add(account);
                } else {
                    accountsWithTerritoryByTerritoryId.put(account.EUR_CRM_Territory__c, new List<EUR_CRM_Account__c> { account });
                }
            }
        }
        return accountsWithTerritoryByTerritoryId;
    }

    private Map<Id, List<EUR_CRM_Account__c>> configureAccountsByTerritoryId(List<EUR_CRM_Account__c> accounts) {
        Map<Id, List<EUR_CRM_Account__c>> accountsByTerritoryId = new Map<Id, List<EUR_CRM_Account__c>>();
        for (EUR_CRM_Account__c account : accounts) {
            if (accountsByTerritoryId.containsKey(account.EUR_CRM_Territory__c)) {
                accountsByTerritoryId.get(account.EUR_CRM_Territory__c).add(account);
            } else {
                accountsByTerritoryId.put(account.EUR_CRM_Territory__c, new List<EUR_CRM_Account__c> { account });
            }
        }
        return accountsByTerritoryId;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<Id, String> getRTDeveloperNameByRTId(List<EUR_CRM_Account__c> accounts) {
        List<RecordType> recordTypes = this.selectRecordTypesWhereIds(this.extractRecordTypeIds(accounts));

        Map<Id, String> rtDevNameByRTId = new Map<Id, String>();
        for (RecordType rt : recordTypes) {
            rtDevNameByRTId.put(rt.Id, rt.DeveloperName);
        }
        return rtDevNameByRTId;
    }

    private Set<Id> extractRecordTypeIds(List<EUR_CRM_Account__c> accounts) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (EUR_CRM_Account__c account : accounts) {
            recordTypeIds.add(account.RecordTypeId);
        }
        return recordTypeIds;
    }

    private Map<Id, List<EUR_CRM_Territory__c>> getTerritoriesByOwnerId(List<EUR_CRM_Territory__c> territories) {
        Map<Id, List<EUR_CRM_Territory__c>> territoriesByOwnerId = new Map<Id, List<EUR_CRM_Territory__c>>();
        for (EUR_CRM_Territory__c territory : territories) {
            if (territoriesByOwnerId.containsKey(territory.EUR_CRM_Territory_Owner__c)) {
                territoriesByOwnerId.get(territory.EUR_CRM_Territory_Owner__c).add(territory);
            } else {
                territoriesByOwnerId.put(territory.EUR_CRM_Territory_Owner__c, new List<EUR_CRM_Territory__c> { territory });
            }
        }
        return territoriesByOwnerId;
    }

    private List<EUR_CRM_Account__c> getAccountsWithChangedTerritoryOrImageLevel(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accountsWithChangedTerritoryOrImageLevel = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : accounts) {
            if (this.isNeedToUpdateAccountOwner(account, oldAccountById)) {
                accountsWithChangedTerritoryOrImageLevel.add(account);
            }
        }
        return accountsWithChangedTerritoryOrImageLevel;
    }

    private Set<Id> extractImageLevelIds(Map<Id, List<EUR_CRM_Account__c>> accountsByTerritoryId) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (List<EUR_CRM_Account__c> accounts : accountsByTerritoryId.values()) {
            for (EUR_CRM_Account__c account : accounts) {
                if (account.EUR_CRM_PRS_Image_Level__c != null) {
                    recordTypeIds.add(account.EUR_CRM_PRS_Image_Level__c);
                }
            }
        }
        return recordTypeIds;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isNeedToPopulateTerritory(EUR_CRM_Account__c acc, Map<Id, String> rtDevNameByRTId) {
        return ! this.hasTerritory(acc)
            && ACCOUNT_RECORD_TYPES_TO_SET_TERRITORY_DEPENDING_ON_ACCOUNT_OWNER.contains(rtDevNameByRTId.get(acc.RecordTypeId))
        ;
    }

    private Boolean isNeedToUpdateAccountOwner(EUR_CRM_Account__c acc, Map<Id, String> rtDevNameByRTId) {
        return this.hasTerritory(acc)
            && ACCOUNT_RECORD_TYPES_TO_SET_ACCOUNT_OWNER_DEPENDING_ON_TERRITORY.contains(rtDevNameByRTId.get(acc.RecordTypeId))
        ;
    }

    private Boolean isNeedToUpdateAccountOwner(EUR_CRM_Account__c acc, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return this.hasTerritory(acc)
            && (acc.EUR_CRM_Territory__c != oldAccountById.get(acc.Id).EUR_CRM_Territory__c
            || acc.EUR_CRM_PRS_Image_Level__c != oldAccountById.get(acc.Id).EUR_CRM_PRS_Image_Level__c)
        ;
    }

    private Boolean hasTerritory(EUR_CRM_Account__c account) {
        return account.EUR_CRM_Territory__c != null;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<RecordType> selectRecordTypesWhereIds(Set<Id> rtIds) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE Id IN :rtIds
        ];
    }

    private List<EUR_CRM_Territory__c> selectTerritory(Set<Id> terrIds, Set<Id> ownerIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Territory_Owner__c
            ,   RecordType.DeveloperName
            ,   EUR_CRM_Default__c
            ,   EUR_CRM_Territory_Channel__c
            ,   EUR_CRM_On_Trade_Owner__c
            ,   EUR_CRM_Off_Trade_Owner__c
            ,   EUR_CRM_KD_Owner__c
            FROM EUR_CRM_Territory__c
            WHERE (
                Id IN :terrIds
                OR EUR_CRM_Territory_Owner__c IN :ownerIds
                OR EUR_CRM_On_Trade_Owner__c IN :ownerIds
                OR EUR_CRM_Off_Trade_Owner__c IN :ownerIds
                OR EUR_CRM_KD_Owner__c IN :ownerIds
            )
                AND (
                    EUR_CRM_Territory_Owner__r.IsActive = TRUE
                    OR EUR_CRM_On_Trade_Owner__r.IsActive = TRUE
                    OR EUR_CRM_Off_Trade_Owner__r.IsActive = TRUE
                    OR EUR_CRM_KD_Owner__r.IsActive = TRUE
                )
        ];
    }

    private Map<Id, EUR_CRM_Territory__c> selectTerritoryById(Set<Id> terrIds) {
        return new Map<Id, EUR_CRM_Territory__c>([
            SELECT Id
            ,   EUR_CRM_Territory_Owner__c
            ,   EUR_CRM_On_Trade_Owner__c
            ,   EUR_CRM_Off_Trade_Owner__c
            ,   EUR_CRM_KD_Owner__c
            FROM EUR_CRM_Territory__c
            WHERE Id IN :terrIds
                AND (
                    EUR_CRM_Territory_Owner__r.IsActive = TRUE
                    OR EUR_CRM_On_Trade_Owner__r.IsActive = TRUE
                    OR EUR_CRM_Off_Trade_Owner__r.IsActive = TRUE
                    OR EUR_CRM_KD_Owner__r.IsActive = TRUE
                )
        ]);
    }

    private Map<Id, EUR_CRM_PRS_Seg_Aspect__c> selectImageLevelById(Set<Id> ids) {
        return new Map<Id, EUR_CRM_PRS_Seg_Aspect__c>([
            SELECT Id
            ,   EUR_CRM_Segmentation_IL_Aspect_Name__c
            FROM EUR_CRM_PRS_Seg_Aspect__c
            WHERE Id IN :ids
        ]);
    }
}