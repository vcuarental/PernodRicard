public with sharing class EUR_CRM_AssignAccountCustomerTaxonomy extends EUR_CRM_TriggerAbstract{

    private final Map<String, String> VALID_TAXONOMY_RT_BY_ACCOUNT_RT = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(
        EUR_CRM_AssignAccountCustomerTaxonomy.class.getName(), 'VALID_TAXONOMY_RT_BY_ACCOUNT_RT');
//    private final Map<String, String> VALID_TAXONOMY_RT_BY_ACCOUNT_RT = new Map<String, String> {
//        'EUR_BG_Wholesaler'             => 'EUR_BG_Wholesalers_Customer_Taxonomy'
//    ,   'EUR_BG_Traditional_Off_Trade'  => 'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy'
//    };

    public EUR_CRM_AssignAccountCustomerTaxonomy(){
        super('EUR_CRM_AssignAccountCustomerTaxonomy');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        Map<Id, RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById();

        List<EUR_CRM_Account__c> accountsToUpdate = this.getAccountsToUpdate(sObjList, rtInfoById);
        System.debug('\n accountsToUpdate.size() => ' + accountsToUpdate.size() + '\n');
        System.debug('\n accountsToUpdate => ' + JSON.serializePretty(accountsToUpdate) + '\n');
        if (accountsToUpdate.isEmpty()) { return; }

        Map<String, EUR_CRM_Customer_Taxonomy__c> taxonomyByRTDevName = this.getTaxonomyByRTDevName();
        System.debug('\n taxonomyByRTDevName.size() => ' + taxonomyByRTDevName.size() + '\n');
        System.debug('\n taxonomyByRTDevName => ' + JSON.serializePretty(taxonomyByRTDevName) + '\n');
        if (taxonomyByRTDevName.isEmpty()) { return; }


        List<EUR_CRM_Account__c> updatedAccounts = this.assignTaxonomyToAccounts(accountsToUpdate, taxonomyByRTDevName, rtInfoById);
        System.debug('\n updatedAccounts.size() => ' + updatedAccounts.size() + '\n');
        System.debug('\n updatedAccounts => ' + JSON.serializePretty(updatedAccounts) + '\n');
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private List<EUR_CRM_Account__c> assignTaxonomyToAccounts(List<EUR_CRM_Account__c> accountsToUpdate, Map<String, EUR_CRM_Customer_Taxonomy__c> taxonomyByRTDevName, Map<Id, RecordTypeInfo> rtInfoById) {
        List<EUR_CRM_Account__c> updatedAccounts = new List<EUR_CRM_Account__c>();

        for (EUR_CRM_Account__c acc : accountsToUpdate) {
            String accRT = rtInfoById.get(acc.RecordTypeId).getDeveloperName();
            if ( ! VALID_TAXONOMY_RT_BY_ACCOUNT_RT.containsKey(accRT)) { continue; }
            String taxonomyRT = VALID_TAXONOMY_RT_BY_ACCOUNT_RT.get(accRT);
            if ( ! taxonomyByRTDevName.containsKey(taxonomyRT)) { continue; }

            this.assignTaxonomyToAccount(taxonomyByRTDevName, taxonomyRT, acc);
            updatedAccounts.add(acc);
        }
        return updatedAccounts;
    }

    private void assignTaxonomyToAccount(Map<String, EUR_CRM_Customer_Taxonomy__c> taxonomyByRTDevName, String taxonomyRT, EUR_CRM_Account__c acc) {
        EUR_CRM_Customer_Taxonomy__c taxonomy = taxonomyByRTDevName.get(taxonomyRT);
        acc.EUR_JB_Customer_Taxonomy__c = taxonomy.Id;
    }

    private List<EUR_CRM_Account__c> getAccountsToUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, RecordTypeInfo> rtInfoById) {
        List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accounts) {
            if ( ! rtInfoById.containsKey(acc.RecordTypeId)) { continue; }
            String rtDevName = rtInfoById.get(acc.RecordTypeId).getDeveloperName();
            if (VALID_TAXONOMY_RT_BY_ACCOUNT_RT.keySet().contains(rtDevName)) {
                accountsToUpdate.add(acc);
            }
        }
        return accountsToUpdate;
    }

    private Map<String, EUR_CRM_Customer_Taxonomy__c> getTaxonomyByRTDevName() {
        List<EUR_CRM_Customer_Taxonomy__c> taxonomies = this.selectCustomerTaxonomiesWhereRTDevNames(VALID_TAXONOMY_RT_BY_ACCOUNT_RT.values());

        Map<String, EUR_CRM_Customer_Taxonomy__c> taxonomyByRTDEvName = new Map<String, EUR_CRM_Customer_Taxonomy__c>();
        for (EUR_CRM_Customer_Taxonomy__c taxonomy : taxonomies) {
            taxonomyByRTDEvName.put(taxonomy.RecordType.DeveloperName, taxonomy);
        }
        return taxonomyByRTDEvName;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Customer_Taxonomy__c> selectCustomerTaxonomiesWhereRTDevNames(List<String> rtDevNames) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            FROM EUR_CRM_Customer_Taxonomy__c
            WHERE RecordType.DeveloperName IN :rtDevNames
        ];
    }

}