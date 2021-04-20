public with sharing class EUR_CRM_AccountListingTemplateHandler {

    private static final String CURRENT_CLASS_NAME = 'EUR_CRM_AccountListingTemplateHandler';
    private static final String VARIABLE_NAME = 'validListingTemplateRTByAccountRT';

    private static final Map<String, String> validListingTemplateRTByAccountRT = EUR_CRM_RecordTypeHelper_v2.getSettingsMap(CURRENT_CLASS_NAME, VARIABLE_NAME);

//    private static Map<String, String> validListingTemplateRTByAccountRT = new Map<String, String>{
//          'EUR_IT_Enoteca_Account' => 'EUR_IT_Enoteca_Template'
//        , 'EUR_IT_Wholesaler_Account' => 'EUR_IT_Wholesaler_Template'
//    };

    private static final String IT_ENOTECA_ACCOUNT_REC_TYPE = 'EUR_IT_Enoteca_Account';

    public void onBeforeInsert(List<EUR_CRM_Account__c> accounts) {
        Map<Id, RecordTypeInfo> accRtInfoById = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById();

        List<EUR_CRM_Account__c> accountsToUpdate = this.getAccountsToUpdate(accounts, accRtInfoById);
        if (accountsToUpdate.isEmpty()) { return; }

        Map<String, EUR_CRM_JB_Template__c> listingTemplateByCustKey = this.getListingTemplatesByCustKey();
        if (listingTemplateByCustKey.isEmpty()) { return; }

        this.assignListingTemplate(accountsToUpdate, accRtInfoById, listingTemplateByCustKey);
    }

    public void onBeforeUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        Map<Id, RecordTypeInfo> accRtInfoById = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById();

        List<EUR_CRM_Account__c> accountsToUpdate = this.getAccountsToUpdate(accounts, oldAccountById, accRtInfoById);
        if (accountsToUpdate.isEmpty()) { return; }

        Map<String, EUR_CRM_JB_Template__c> listingTemplateByCustKey = this.getListingTemplatesByCustKey();
        if (listingTemplateByCustKey.isEmpty()) { return; }

        this.assignListingTemplate(accountsToUpdate, accRtInfoById, listingTemplateByCustKey);
    }


    /*============================================*/
    /* High level helpers
    /*============================================*/
    private List<EUR_CRM_Account__c> getAccountsToUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, RecordTypeInfo> accRtInfoById) {
        List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accounts) {
            if ( ! validListingTemplateRTByAccountRT.containsKey(accRtInfoById.get(acc.RecordTypeId).getDeveloperName())) { continue; }
            accountsToUpdate.add(acc);
        }
        return accountsToUpdate;
    }

    private List<EUR_CRM_Account__c> getAccountsToUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccById, Map<Id, RecordTypeInfo> accRtInfoById) {
        List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : accounts) {
            if (validListingTemplateRTByAccountRT.containsKey(accRtInfoById.get(acc.RecordTypeId).getDeveloperName())
                && this.isSegmentationChanged(acc, oldAccById.get(acc.Id))) {
                accountsToUpdate.add(acc);
            }
        }
        return accountsToUpdate;
    }

    private Map<String, EUR_CRM_JB_Template__c> getListingTemplatesByCustKey() {
        List<EUR_CRM_JB_Template__c> listingTemplates = this.selectListingTemplatesWhereRTs();
        if (listingTemplates.isEmpty()) { return new Map<String, EUR_CRM_JB_Template__c>(); }

        Map<String, EUR_CRM_JB_Template__c> ltByCustKey = new Map<String, EUR_CRM_JB_Template__c>();
        for (EUR_CRM_JB_Template__c template : listingTemplates) {
            String custKey = template.RecordType.DeveloperName + template.EUR_CRM_Segmentation__c;
            ltByCustKey.put(custKey, template);
        }
        return ltByCustKey;
    }

    private void assignListingTemplate(List<EUR_CRM_Account__c> accountsToUpdate, Map<Id, RecordTypeInfo> accRtInfoById, Map<String, EUR_CRM_JB_Template__c> listingTemplateByCustKey) {
        for (EUR_CRM_Account__c acc : accountsToUpdate) {
            String accRtDevName = accRtInfoById.get(acc.RecordTypeId).getDeveloperName();
            String ltRtDevName = this.getAppropriateListingTemplateRt(accRtDevName);
            String custKey = ltRtDevName + acc.EUR_CRM_Segmentation__c;
            if (listingTemplateByCustKey.containsKey(custKey)) {
                acc.EUR_CRM_Listing_Template__c = listingTemplateByCustKey.get(custKey).Id;
            }
        }
    }


    /*============================================*/
    /* Low level helpers
    /*============================================*/
    private String getAppropriateListingTemplateRt(String accRtDevName) {
        if ( ! validListingTemplateRTByAccountRT.containsKey(accRtDevName)) {  return ''; }
        return validListingTemplateRTByAccountRT.get(accRtDevName);
    }

    private Boolean isEnotecaRT(String recordTypeDevName) {
        return recordTypeDevName == IT_ENOTECA_ACCOUNT_REC_TYPE;
    }

    private Boolean isSegmentationChanged(EUR_CRM_Account__c acc, EUR_CRM_Account__c oldAcc) {
        return acc.EUR_CRM_Segmentation__c != oldAcc.EUR_CRM_Segmentation__c;
    }


    /*============================================*/
    /* SOQL Selectors
    /*============================================*/
    private List<EUR_CRM_JB_Template__c> selectListingTemplatesWhereRTs() {
        return [
            SELECT Id
                , EUR_CRM_Segmentation__c
                , RecordType.DeveloperName
            FROM EUR_CRM_JB_Template__c
            WHERE RecordType.DeveloperName IN :validListingTemplateRTByAccountRT.values()
        ];
    }
}