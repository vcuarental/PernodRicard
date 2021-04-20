public with sharing class EUR_CRM_TemplateAssignmentHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_TemplateAssignmentHandler() { super('EUR_CRM_TemplateAssignmentHandler'); }

    private final String GROUP_OUTLET_TYPE = 'GROUP_OUTLET_TYPE';
    private final String OUTLET_TYPE = 'OUTLET_TYPE';
    private final String IMAGE_LEVEL = 'IMAGE_LEVEL';
    private final String VOLUME_POTENTIAL = 'VOLUME_POTENTIAL';
    private final String CUSTOM_TAXONOMY = 'CUSTOM_TAXONOMY';

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if(tAction == TriggerAction.BEFORE_INSERT) {
            this.onBeforeInsert((List<EUR_CRM_Account__c>)sObjList);
        }

        if(tAction == TriggerAction.BEFORE_UPDATE) {
            this.onBeforeUpdate((List<EUR_CRM_Account__c>)sObjList, (Map<Id, EUR_CRM_Account__c>)oldMap);
        }
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void onBeforeInsert(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Account__c> accountsWithRequiredData = this.getAccountsToUpdate(accounts);
        System.debug('\n\n accountsWithRequiredData => ' + JSON.serializePretty(accountsWithRequiredData) + '\n');
        if (accountsWithRequiredData.isEmpty()) { return ; }

        this.populateDefaultTemplate(accountsWithRequiredData);
    }

    private void onBeforeUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accountsWithChangedRequiredData = this.getAccountsToUpdate(accounts, oldAccountById);
        System.debug('\n\n accountsWithChangedRequiredData => ' + JSON.serializePretty(accountsWithChangedRequiredData) + '\n');
        if (accountsWithChangedRequiredData.isEmpty()) { return ; }

        this.populateDefaultTemplate(accountsWithChangedRequiredData);
    }

    private void populateDefaultTemplate(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Account__c> segmentationAccountsToUpdate = this.getSegmentationAccountsToUpdate(accounts);
        System.debug('\n\n segmentationAccountsToUpdate => ' + JSON.serializePretty(segmentationAccountsToUpdate) + '\n');

        List<EUR_CRM_Account__c> taxonomyAccountsToUpdate = this.getTaxonomyAccountsToUpdate(accounts);
        System.debug('\n\n taxonomyAccountsToUpdate => ' + JSON.serializePretty(taxonomyAccountsToUpdate) + '\n');

        Map<String, Set<Id>> dataSetByType = this.initDataSetByType(accounts);
        System.debug('\n\n dataSetByType => ' + JSON.serializePretty(dataSetByType) + '\n');

        if( ! segmentationAccountsToUpdate.isEmpty()) {
            this.populateBySegmentation(segmentationAccountsToUpdate, dataSetByType);
        } else if ( ! taxonomyAccountsToUpdate.isEmpty()) {
            this.populateByTaxonomy(taxonomyAccountsToUpdate, dataSetByType);
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private void populateBySegmentation(List<EUR_CRM_Account__c> accounts, Map<String, Set<Id>> dataSetByType) {
        Map<String, EUR_CRM_JB_Template_Criteria__c> templateCriteriaByKey = this.getTemplateCriteriaByKey(dataSetByType);
        System.debug('\n\n templateCriteriaByKey => ' + JSON.serializePretty(templateCriteriaByKey) + '\n');
        if (templateCriteriaByKey.isEmpty()) { return ; }

        Map<Id, RecordType> recordTypeById = this.getRecordTypeById(accounts);
        for (EUR_CRM_Account__c acc : accounts) {
            String key = createKey(acc.EUR_CRM_Group_Outlet_Type__c, acc.EUR_CRM_Outlet_Type__c, acc.EUR_CRM_Image_Level__c, acc.EUR_CRM_Volume_Potential__c, recordTypeById.get(acc.RecordTypeId).DeveloperName);
            if (templateCriteriaByKey.containsKey(key)) {
                acc.EUR_JB_Default_Template__c = templateCriteriaByKey.get(key).EUR_JB_Template__c;
            } else {
                acc.EUR_JB_Default_Template__c = null;
            }
        }
    }

    private void populateByTaxonomy(List<EUR_CRM_Account__c> accounts, Map<String, Set<Id>> dataSetByType) {
        Map<Id, EUR_CRM_Customer_Taxonomy__c> customerTaxonomyById = this.selectCustomerTaxonomyById(dataSetByType.get(CUSTOM_TAXONOMY));
        System.debug('\n\n customerTaxonomyById => ' + JSON.serializePretty(customerTaxonomyById) + '\n');
        if (customerTaxonomyById.isEmpty()) { return ; }

        for (EUR_CRM_Account__c acc : accounts) {
            if (customerTaxonomyById.containsKey(acc.EUR_JB_Customer_Taxonomy__c)) {
                acc.EUR_JB_Default_Template__c = customerTaxonomyById.get(acc.EUR_JB_Customer_Taxonomy__c).EUR_JB_Template__c;
            } else {
                acc.EUR_JB_Default_Template__c = null;
            }
        }
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Account__c> getAccountsToUpdate(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Account__c> accountsWithChangedRequiredData = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : accounts) {
            if (this.isRequiredDataExist(account)) {
                accountsWithChangedRequiredData.add(account);
            }
        }
        return accountsWithChangedRequiredData;
    }

    private List<EUR_CRM_Account__c> getAccountsToUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_Account__c> accountsWithChangedRequiredData = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : accounts) {
            if (this.isRequiredDataChanged(account, oldAccountById)) {
                accountsWithChangedRequiredData.add(account);
            }
        }
        return accountsWithChangedRequiredData;
    }

    private Map<String, Set<Id>> initDataSetByType(List<EUR_CRM_Account__c> accounts) {
        Map<String, Set<Id>> dataSetByType = new Map<String, Set<Id>> {
            GROUP_OUTLET_TYPE => new Set<Id>()
        ,   OUTLET_TYPE => new Set<Id>()
        ,   IMAGE_LEVEL => new Set<Id>()
        ,   VOLUME_POTENTIAL => new Set<Id>()
        ,   CUSTOM_TAXONOMY => new Set<Id>()
        };
        for (EUR_CRM_Account__c account : accounts) {
            if (this.isRequiredDataExist(account)) {
                dataSetByType.get(GROUP_OUTLET_TYPE).add(account.EUR_CRM_Group_Outlet_Type__c);
                dataSetByType.get(OUTLET_TYPE).add(account.EUR_CRM_Outlet_Type__c);
                dataSetByType.get(IMAGE_LEVEL).add(account.EUR_CRM_Image_Level__c);
                dataSetByType.get(VOLUME_POTENTIAL).add(account.EUR_CRM_Volume_Potential__c);
                dataSetByType.get(CUSTOM_TAXONOMY).add(account.EUR_JB_Customer_Taxonomy__c);
            }
        }
        return dataSetByType;
    }

    private List<EUR_CRM_Account__c> getSegmentationAccountsToUpdate(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Account__c> segmentationAccounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accounts) {
            if (this.isSegmentationDataExist(acc)) {
                segmentationAccounts.add(acc);
            }
        }
        return segmentationAccounts;
    }

    private List<EUR_CRM_Account__c> getTaxonomyAccountsToUpdate(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Account__c> taxonomyAccounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accounts) {
            if (this.isTaxonomyDataExist(acc)) {
                taxonomyAccounts.add(acc);
            }
        }
        return taxonomyAccounts;
    }

    private Map<Id, RecordType> getRecordTypeById(List<EUR_CRM_Account__c> accounts) {
        Set<Id> recordTypeIds = this.extractRecordTypeIds(accounts);

        return this.selectRecordTypeByIdWhereIds(recordTypeIds);
    }

    private Map<String, EUR_CRM_JB_Template_Criteria__c> getTemplateCriteriaByKey(Map<String, Set<Id>> dataSetByType) {
        List<EUR_CRM_JB_Template_Criteria__c> templateCriteria = this.selectTemplateCriteria(dataSetByType);

        Map<String, EUR_CRM_JB_Template_Criteria__c> templateCriteriaByKey = new Map<String, EUR_CRM_JB_Template_Criteria__c>();
        for (EUR_CRM_JB_Template_Criteria__c tc : templateCriteria) {
            String key = createKey(tc.EUR_JB_Group_Outlet_Type__c, tc.EUR_JB_Outlet_Type__c, tc.EUR_JB_Image_Level__c, tc.EUR_JB_Volume_Potential__c, tc.EUR_JB_Template__r.EUR_CRM_Record_Type_Name__c);
            templateCriteriaByKey.put(key, tc);
        }
        return templateCriteriaByKey;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isRequiredDataExist(EUR_CRM_Account__c account) {
        return this.isSegmentationDataExist(account)
            || this.isTaxonomyDataExist(account)
        ;
    }

    private Boolean isRequiredDataChanged(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        return this.isRequiredDataExist(account)
            && (
            account.EUR_CRM_Group_Outlet_Type__c != oldAccountById.get(account.Id).EUR_CRM_Group_Outlet_Type__c
            || account.EUR_CRM_Outlet_Type__c != oldAccountById.get(account.Id).EUR_CRM_Outlet_Type__c
            || account.EUR_CRM_Image_Level__c != oldAccountById.get(account.Id).EUR_CRM_Image_Level__c
            || account.EUR_CRM_Volume_Potential__c != oldAccountById.get(account.Id).EUR_CRM_Volume_Potential__c
            || account.EUR_JB_Customer_Taxonomy__c != oldAccountById.get(account.Id).EUR_JB_Customer_Taxonomy__c
        )
        ;
    }

    private Boolean isSegmentationDataExist(EUR_CRM_Account__c account) {
        return account.EUR_CRM_Group_Outlet_Type__c != null
            && account.EUR_CRM_Outlet_Type__c != null
            && account.EUR_CRM_Image_Level__c != null
            && account.EUR_CRM_Volume_Potential__c != null
        ;
    }

    private Boolean isTaxonomyDataExist(EUR_CRM_Account__c account) {
        return account.EUR_JB_Customer_Taxonomy__c != null;
    }

    private Set<Id> extractRecordTypeIds(List<EUR_CRM_Account__c> accounts) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (EUR_CRM_Account__c account : accounts) {
            recordTypeIds.add(account.RecordTypeId);
        }
        return recordTypeIds;
    }

    private String createKey(String g, String o, String i, String v, String recordTypeName){
        return g + '-' + o + '-' + i + '-' + v + recordTypeName.substring(0, 6);
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private Map<Id, RecordType> selectRecordTypeByIdWhereIds(Set<Id> rtIds) {
        return new Map<Id, RecordType>([
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE Id = :rtIds
        ]);
    }

    private List<EUR_CRM_JB_Template_Criteria__c> selectTemplateCriteria(Map<String, Set<Id>> dataSetByType) {
        return [
            SELECT Id
            ,   EUR_JB_Template__r.EUR_CRM_Record_Type_Name__c
            ,   EUR_JB_External_ID__c
            ,   EUR_JB_Group_Outlet_Type__c
            ,   EUR_JB_Image_Level__c
            ,   EUR_JB_Outlet_Type__c
            ,   EUR_JB_Template__c
            ,   EUR_JB_Volume_Potential__c
            FROM EUR_CRM_JB_Template_Criteria__c
            WHERE EUR_JB_Group_Outlet_Type__c IN :dataSetByType.get(GROUP_OUTLET_TYPE)
                AND EUR_JB_Outlet_Type__c IN :dataSetByType.get(OUTLET_TYPE)
                AND EUR_JB_Image_Level__c IN :dataSetByType.get(IMAGE_LEVEL)
                AND EUR_JB_Volume_Potential__c IN :dataSetByType.get(VOLUME_POTENTIAL)
                AND EUR_JB_Active__c = TRUE
        ];
    }

    private Map<Id, EUR_CRM_Customer_Taxonomy__c> selectCustomerTaxonomyById(Set<Id> customerTaxonomyIds) {
        return new Map<Id, EUR_CRM_Customer_Taxonomy__c>([
            SELECT Id
            ,    EUR_JB_Template__c
            FROM EUR_CRM_Customer_Taxonomy__c
            WHERE Id = :customerTaxonomyIds
                AND EUR_JB_Template__c != NULL
        ]);
    }
    
}