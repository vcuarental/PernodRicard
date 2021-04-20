public with sharing class EUR_CRM_AccountContractMapHandler {

    @TestVisible private final static String OUTLET = 'Outlet';
    @TestVisible private final static String HEAD_OFFICE = 'Head Office';

    private static final String CLASS_NAME = 'EUR_CRM_AccountContractMapHandler';

    private final Set<String> ALL_VALID_ACCOUNT_RECORD_TYPES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'ALL_VALID_ACCOUNT_RECORD_TYPES');
//    private final Set<String> ALL_VALID_ACCOUNT_RECORD_TYPES = new Set<String> {
//        'EUR_FI_Indirect_On_Trade'
//    ,   'EUR_FI_Direct_On_Trade'
//    ,   'EUR_NL_On_Trade'
//    };

    private final Set<String> ALL_VALID_CONTRACT_RECORD_TYPES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'ALL_VALID_CONTRACT_RECORD_TYPES');
//    private final Set<String> ALL_VALID_CONTRACT_RECORD_TYPES = new Set<String> {
//        'EUR_FI_Chain_Contract'
//    ,   'EUR_NL_Chain_Contract'
//    };

    private final Map<String, String> CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(CLASS_NAME, 'CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES');
//    private final Map<String, String> CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES = new Map<String, String> {
//        'EUR_FI_Indirect_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
//    ,   'EUR_FI_Direct_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
//    ,   'EUR_NL_On_Trade' => 'EUR_NL_Contract_Account_Mapping'
//    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleAccounts(List<EUR_CRM_Account__c> insertedAccounts) {
        List<EUR_CRM_Account__c> accountsToCreateLinkWithContracts = this.extractAccountsToCreateLinkWithContracts(insertedAccounts);
        System.debug('\n\n accountsToCreateLinkWithContracts.size() => ' + JSON.serializePretty(accountsToCreateLinkWithContracts.size()) + '\n');
        System.debug('\n\n accountsToCreateLinkWithContracts => ' + JSON.serializePretty(accountsToCreateLinkWithContracts) + '\n');
        if (accountsToCreateLinkWithContracts.isEmpty()) { return ; }

        this.createContractAccountMappings(accountsToCreateLinkWithContracts);
    }

    public void handleAccounts(List<EUR_CRM_Account__c> updatedAccounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accountsToRemoveLinkWithContracts = this.extractAccountsToRemoveLinkWithContracts(updatedAccounts, oldAccountById);
        System.debug('\n\n accountsToRemoveLinkWithContracts.size() => ' + JSON.serializePretty(accountsToRemoveLinkWithContracts.size()) + '\n');
        System.debug('\n\n accountsToRemoveLinkWithContracts => ' + JSON.serializePretty(accountsToRemoveLinkWithContracts) + '\n');

        List<EUR_CRM_Account__c> accountsToCreateLinkWithContracts = this.extractAccountsToCreateLinkWithContracts(updatedAccounts, oldAccountById);
        System.debug('\n\n accountsToCreateLinkWithContracts.size() => ' + JSON.serializePretty(accountsToCreateLinkWithContracts.size()) + '\n');
        System.debug('\n\n accountsToCreateLinkWithContracts => ' + JSON.serializePretty(accountsToCreateLinkWithContracts) + '\n');

        if( ! accountsToRemoveLinkWithContracts.isEmpty()) {
            this.removeContractAccountMappings(accountsToRemoveLinkWithContracts);
        }

        if ( ! accountsToCreateLinkWithContracts.isEmpty()) {
            this.createContractAccountMappings(accountsToCreateLinkWithContracts);
        }
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void createContractAccountMappings(List<EUR_CRM_Account__c> accountsToCreateLinkWithContracts) {
        Map<Id, List<EUR_CRM_Account__c>> accountsByParentAccountId = this.configureAccountsByParentAccountId(accountsToCreateLinkWithContracts);
        System.debug('\n\n accountsByParentAccountId.size() => ' + JSON.serializePretty(accountsByParentAccountId.size()) + '\n');
        System.debug('\n\n accountsByParentAccountId => ' + JSON.serializePretty(accountsByParentAccountId) + '\n');

        Map<Id, Set<Id>> contractIdsByAccountId = this.getContractIdsByAccountId(accountsByParentAccountId.keySet());
        System.debug('\n\n contractIdsByAccountId.size() => ' + JSON.serializePretty(contractIdsByAccountId.size()) + '\n');
        System.debug('\n\n contractIdsByAccountId => ' + JSON.serializePretty(contractIdsByAccountId) + '\n');
        if (contractIdsByAccountId.isEmpty()) { return ; }

        Map<Id, Schema.RecordTypeInfo> accRTInfoById = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById();
        Map<String, Schema.RecordTypeInfo> camRTInfoByDevName = Schema.SObjectType.EUR_CRM_Contract_Account_Mapping__c.getRecordTypeInfosByDeveloperName();
        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsToInsert = new List<EUR_CRM_Contract_Account_Mapping__c>();
        for (Id parentId : contractIdsByAccountId.keySet()) {
            for (Id contractId : contractIdsByAccountId.get(parentId)) {
                for (EUR_CRM_Account__c account : accountsByParentAccountId.get(parentId)) {
                    String accountRTDevName = accRTInfoById.get(account.RecordTypeId).getDeveloperName();
                    if ( ! ALL_VALID_ACCOUNT_RECORD_TYPES.contains(accountRTDevName)) { continue; }

                    String rtDevName = CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES.get(accountRTDevName);
                    Id rtId = camRTInfoByDevName.get(rtDevName).getRecordTypeId();
                    contractAccountMappingsToInsert.add(this.makeContractAccountMapping(rtId, contractId, account.Id));
                }
            }
        }
        System.debug('\n\n contractAccountMappingsToInsert.size() => ' + JSON.serializePretty(contractAccountMappingsToInsert.size()) + '\n');
        System.debug('\n\n contractAccountMappingsToInsert => ' + JSON.serializePretty(contractAccountMappingsToInsert) + '\n');
        insert contractAccountMappingsToInsert;
    }

    private void removeContractAccountMappings(List<EUR_CRM_Account__c> accountsToRemoveLinkWithContracts) {
        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsToDelete = this.selectContractAccountMappingsWhereAccountId(new Map<Id, EUR_CRM_Account__c>(accountsToRemoveLinkWithContracts).keySet());
        System.debug('\n\n contractAccountMappingsToDelete.size() => ' + JSON.serializePretty(contractAccountMappingsToDelete.size()) + '\n');
        System.debug('\n\n contractAccountMappingsToDelete => ' + JSON.serializePretty(contractAccountMappingsToDelete) + '\n');
        if (contractAccountMappingsToDelete.isEmpty()) { return ; }

        delete contractAccountMappingsToDelete;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_Account__c>> configureAccountsByParentAccountId(List<EUR_CRM_Account__c> accounts) {
        Map<Id, List<EUR_CRM_Account__c>> accountsByParentAccountId = new Map<Id, List<EUR_CRM_Account__c>>();
        for (EUR_CRM_Account__c account : accounts) {
            if (accountsByParentAccountId.containsKey(account.EUR_CRM_Parent_Account__c)) {
                accountsByParentAccountId.get(account.EUR_CRM_Parent_Account__c).add(account);
            } else {
                accountsByParentAccountId.put(account.EUR_CRM_Parent_Account__c, new List<EUR_CRM_Account__c> { account });
            }
        }
        return accountsByParentAccountId;
    }

    private Map<Id, Set<Id>> getContractIdsByAccountId(Set<Id> accIds) {
        List<EUR_CRM_Contract__c> contracts = this.selectContractsWhereAccountId(accIds);

        Map<Id, Set<Id>> contractIdsByAccountId = new Map<Id, Set<Id>>();
        for (EUR_CRM_Contract__c contract : contracts) {
            if (contractIdsByAccountId.containsKey(contract.EUR_CRM_Account__c)) {
                contractIdsByAccountId.get(contract.EUR_CRM_Account__c).add(contract.Id);
            } else {
                contractIdsByAccountId.put(contract.EUR_CRM_Account__c, new Set<Id> { contract.Id });
            }
        }
        return contractIdsByAccountId;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Account__c> extractAccountsToCreateLinkWithContracts(List<EUR_CRM_Account__c> insertedAccounts) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : insertedAccounts) {
            if (this.isValidAccountToCreateLinkWithContracts(account)) {
                accounts.add(account);
            }
        }
        return accounts;
    }

    private List<EUR_CRM_Account__c> extractAccountsToCreateLinkWithContracts(List<EUR_CRM_Account__c> insertedAccounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : insertedAccounts) {
            if (this.isValidAccountToCreateLinkWithContracts(account, oldAccountById)) {
                accounts.add(account);
            }
        }
        return accounts;
    }

    private List<EUR_CRM_Account__c> extractAccountsToRemoveLinkWithContracts(List<EUR_CRM_Account__c> insertedAccounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : insertedAccounts) {
            if (this.isValidAccountToRemoveLinkWithContracts(account, oldAccountById)) {
                accounts.add(account);
            }
        }
        return accounts;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isValidAccountToCreateLinkWithContracts(EUR_CRM_Account__c account) {
        return account.EUR_CRM_Parent_Account__c != null
            && account.EUR_CRM_Business_Type__c == OUTLET
        ;
    }

    private Boolean isValidAccountToCreateLinkWithContracts(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return this.isParentAccountChanged(account, oldAccountById)
            && this.isValidAccountToCreateLinkWithContracts(account)
        ;
    }

    private Boolean isParentAccountChanged(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return account.EUR_CRM_Parent_Account__c != oldAccountById.get(account.Id).EUR_CRM_Parent_Account__c;
    }

    private Boolean isValidAccountToRemoveLinkWithContracts(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return this.isValidAccountToCreateLinkWithContracts(account, oldAccountById)
            || this.isBusinessTypeChangedTo(account, oldAccountById, HEAD_OFFICE)
            || this.isRemovedLinkToParent(account, oldAccountById)
        ;
    }

    private Boolean isBusinessTypeChangedTo(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById, String businessType) {
        return this.isBusinessTypeChanged(account, oldAccountById)
            && account.EUR_CRM_Business_Type__c == businessType
        ;
    }

    private Boolean isBusinessTypeChanged(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return account.EUR_CRM_Business_Type__c != oldAccountById.get(account.Id).EUR_CRM_Business_Type__c;
    }

    private Boolean isRemovedLinkToParent(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return account.EUR_CRM_Parent_Account__c == null
            && oldAccountById.get(account.Id).EUR_CRM_Parent_Account__c != null
        ;
    }

    private EUR_CRM_Contract_Account_Mapping__c makeContractAccountMapping(Id rtId, Id contractId, Id accountId) {
        return new EUR_CRM_Contract_Account_Mapping__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Contract__c = contractId
        ,   EUR_CRM_Account__c = accountId
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Contract__c> selectContractsWhereAccountId(Set<Id> accIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Account__c
            FROM EUR_CRM_Contract__c
            WHERE EUR_CRM_Account__c IN :accIds
                AND EUR_CRM_Status__c = 'Activated'
                AND RecordType.DeveloperName IN :ALL_VALID_CONTRACT_RECORD_TYPES
        ];
    }

    private List<EUR_CRM_Contract_Account_Mapping__c> selectContractAccountMappingsWhereAccountId(Set<Id> accIds) {
        return [
            SELECT Id
            FROM EUR_CRM_Contract_Account_Mapping__c
            WHERE EUR_CRM_Account__c IN :accIds
        ];
    }

}