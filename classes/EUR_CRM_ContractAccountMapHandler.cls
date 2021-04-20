public with sharing class EUR_CRM_ContractAccountMapHandler {

    private static final String CLASS_NAME = 'EUR_CRM_ContractAccountMapHandler';

    private static Integer handleContractsRunCount = 0;

    private final Set<String> ALL_VALID_ACCOUNT_RECORD_TYPES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'ALL_VALID_ACCOUNT_RECORD_TYPES');
    private final Set<String> VALID_CONTRACT_RECORD_TYPES = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'VALID_CONTRACT_RECORD_TYPES');
    private final Map<String, String> CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(CLASS_NAME, 'CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES');

//    private final Set<String> ALL_VALID_ACCOUNT_RECORD_TYPES = new Set<String> {
//        'EUR_FI_Indirect_On_Trade'
//    ,   'EUR_FI_Direct_On_Trade'
//    ,   'EUR_NL_On_Trade'
//    };
//
//    private final Set<String> VALID_CONTRACT_RECORD_TYPES = new Set<String> {
//        'EUR_FI_Chain_Contract'
//    ,   'EUR_NL_Chain_Contract'
//    };
//
//    private final Map<String, String> CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES = new Map<String, String> {
//        'EUR_FI_Indirect_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
//    ,   'EUR_FI_Direct_On_Trade' => 'EUR_FI_Contract_Account_Mapping'
//    ,   'EUR_NL_On_Trade' => 'EUR_NL_Contract_Account_Mapping'
//    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleContracts(List<EUR_CRM_Contract__c> updatedContracts, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        if (handleContractsRunCount == 1) { return; }

        List<EUR_CRM_Contract__c> contractsToCreateLinkWithAccounts = this.extractContractsToCreateLinkWithAccounts(updatedContracts, oldContractById);
        System.debug('\n\n contractsToCreateLinkWithAccounts.size() => ' + JSON.serializePretty(contractsToCreateLinkWithAccounts.size()) + '\n');
        System.debug('\n\n contractsToCreateLinkWithAccounts => ' + JSON.serializePretty(contractsToCreateLinkWithAccounts) + '\n');
        if (contractsToCreateLinkWithAccounts.isEmpty()) { return ; }

        this.createContractAccountMappings(contractsToCreateLinkWithAccounts);

        incrementRunCount();
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void createContractAccountMappings(List<EUR_CRM_Contract__c> contractsToCreateLinkWithAccounts) {
        Map<Id, List<EUR_CRM_Contract__c>> contractsByAccountId = this.configureContractsByAccountId(contractsToCreateLinkWithAccounts);
        System.debug('\n\n contractsByAccountId.size() => ' + JSON.serializePretty(contractsByAccountId.size()) + '\n');
        System.debug('\n\n contractsByAccountId => ' + JSON.serializePretty(contractsByAccountId) + '\n');

        List<EUR_CRM_Account__c> childAccounts = this.selectAccountsWhereParentAccountIn(contractsByAccountId.keySet());
        System.debug('\n\n childAccounts.size() => ' + JSON.serializePretty(childAccounts.size()) + '\n');
        System.debug('\n\n childAccounts => ' + JSON.serializePretty(childAccounts) + '\n');
        if (childAccounts.isEmpty()) { return ; }

        Map<Id, List<EUR_CRM_Account__c>> accountsByParentAccountId = this.configureAccountsByParentAccountId(childAccounts);
        System.debug('\n\n accountsByParentAccountId.size() => ' + JSON.serializePretty(accountsByParentAccountId.size()) + '\n');
        System.debug('\n\n accountsByParentAccountId => ' + JSON.serializePretty(accountsByParentAccountId) + '\n');

        Map<String, Schema.RecordTypeInfo> rtInfoByDevName = Schema.SObjectType.EUR_CRM_Contract_Account_Mapping__c.getRecordTypeInfosByDeveloperName();
        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountMappingsToInsert = new List<EUR_CRM_Contract_Account_Mapping__c>();
        for (Id parentId : accountsByParentAccountId.keySet()) {
            for (EUR_CRM_Account__c account : accountsByParentAccountId.get(parentId)) {
                for (EUR_CRM_Contract__c contract : contractsByAccountId.get(parentId)) {
                    String rtDevName = CONTRACT_ACCOUNT_MAPPING_RT_DEV_NAMES_BY_ACCOUNT_RT_DEV_NAMES.get(account.RecordType.DeveloperName);
                    Id rtId = rtInfoByDevName.get(rtDevName).getRecordTypeId();
                    contractAccountMappingsToInsert.add(this.makeContractAccountMapping(rtId, contract.Id, account.Id));
                }
            }
        }
        System.debug('\n\n contractAccountMappingsToInsert.size() => ' + JSON.serializePretty(contractAccountMappingsToInsert.size()) + '\n');
        System.debug('\n\n contractAccountMappingsToInsert => ' + JSON.serializePretty(contractAccountMappingsToInsert) + '\n');
        insert contractAccountMappingsToInsert;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Contract__c> extractContractsToCreateLinkWithAccounts(List<EUR_CRM_Contract__c> updatedContracts, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        Map<Id, Schema.RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosById();

        List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>();
        for (EUR_CRM_Contract__c contract : updatedContracts) {
            String rtDevName = rtInfoById.get(contract.RecordTypeId).getDeveloperName();
            if (VALID_CONTRACT_RECORD_TYPES.contains(rtDevName) && this.isValidContractToCreateLinkWithAccounts(contract, oldContractById)) {
                contracts.add(contract);
            }
        }
        return contracts;
    }

    private Map<Id, List<EUR_CRM_Contract__c>> configureContractsByAccountId(List<EUR_CRM_Contract__c> contracts) {
        Map<Id, List<EUR_CRM_Contract__c>> contractsByAccountId = new Map<Id, List<EUR_CRM_Contract__c>>();
        for (EUR_CRM_Contract__c contract : contracts) {
            if (contractsByAccountId.containsKey(contract.EUR_CRM_Account__c)) {
                contractsByAccountId.get(contract.EUR_CRM_Account__c).add(contract);
            } else {
                contractsByAccountId.put(contract.EUR_CRM_Account__c, new List<EUR_CRM_Contract__c> { contract });
            }
        }
        return contractsByAccountId;
    }

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


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isValidContractToCreateLinkWithAccounts(EUR_CRM_Contract__c contract, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        return this.isStatusChanged(contract, oldContractById)
            && contract.EUR_CRM_Status__c == 'Activated'
        ;
    }

    private Boolean isStatusChanged(EUR_CRM_Contract__c contract, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        return contract.EUR_CRM_Status__c != oldContractById.get(contract.Id).EUR_CRM_Status__c;
    }

    private EUR_CRM_Contract_Account_Mapping__c makeContractAccountMapping(Id rtId, Id contractId, Id accountId) {
        return new EUR_CRM_Contract_Account_Mapping__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Contract__c = contractId
        ,   EUR_CRM_Account__c = accountId
        );
    }

    private static Integer incrementRunCount() {
        return handleContractsRunCount++;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Account__c> selectAccountsWhereParentAccountIn(Set<Id> parentAccIds) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            ,   EUR_CRM_Parent_Account__c
            FROM EUR_CRM_Account__c
            WHERE EUR_CRM_Parent_Account__c IN :parentAccIds
                AND RecordType.DeveloperName IN :ALL_VALID_ACCOUNT_RECORD_TYPES
        ];
    }

}