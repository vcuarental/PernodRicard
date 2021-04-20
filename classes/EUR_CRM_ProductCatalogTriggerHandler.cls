/**
 * Created by Andrii Leshchuk on 20.02.2019.
 */

public with sharing class EUR_CRM_ProductCatalogTriggerHandler extends EUR_CRM_TriggerHandler {

    private Map<Id, String> productCatalogRecordTypeMap;

    override protected void afterInsert() {
        this.initProductCatalogRecordTypeMap();
        this.updateExternalId(Trigger.new);
    }

    private void updateExternalId(List<EUR_CRM_ProductCatalog__c> productCatalogs) {
        List<EUR_CRM_ProductCatalog__c> productCatalogsForUpdateExternalId = new List<EUR_CRM_ProductCatalog__c>();
        for (EUR_CRM_ProductCatalog__c productCatalog : productCatalogs) {
            this.changeAndAddToListOnlyIndirectAndPosmProductCatalogs(productCatalogsForUpdateExternalId, productCatalog);
        }
        update productCatalogsForUpdateExternalId;
    }

    private void changeAndAddToListOnlyIndirectAndPosmProductCatalogs(List<EUR_CRM_ProductCatalog__c> productCatalogsForUpdateExternalId, EUR_CRM_ProductCatalog__c productCatalog) {

        String recordTypeName = this.productCatalogRecordTypeMap.get(productCatalog.RecordTypeId);
        String externalIdPrefix;
        Boolean isNeedToCreateExtIdForDirect = !productCatalog.EUR_CRM_IsStandard__c;
        if (recordTypeName == 'Direct' && isNeedToCreateExtIdForDirect) {
            externalIdPrefix = 'DIR-';
//            return;
        } else if (recordTypeName == 'Indirect') {
            externalIdPrefix = 'IND-';
        } else if (recordTypeName == 'POSM') {
            externalIdPrefix = 'POSM-';
        } else {
            return;
        }
        String externalId = externalIdPrefix + productCatalog.EUR_CRM_Unique_Number__c;
        productCatalogsForUpdateExternalId.add(new EUR_CRM_ProductCatalog__c(Id = productCatalog.Id
                , EUR_CRM_External_ID__c = externalId));
    }

    private void initProductCatalogRecordTypeMap() {
        this.productCatalogRecordTypeMap = new Map<Id, String>();

        Map<String, Schema.RecordTypeInfo> recordTypeInfoByNameMap = Schema.SObjectType.EUR_CRM_ProductCatalog__c.getRecordTypeInfosByName();

        this.putPairByRecordTypeName(recordTypeInfoByNameMap, 'Direct');
        this.putPairByRecordTypeName(recordTypeInfoByNameMap, 'Indirect');
        this.putPairByRecordTypeName(recordTypeInfoByNameMap, 'POSM');
    }

    private void putPairByRecordTypeName(Map<String, Schema.RecordTypeInfo> recordTypeInfoByNameMap, String recordTypeName) {
        Id recordTypeId = recordTypeInfoByNameMap.get(recordTypeName).getRecordTypeId();
        this.productCatalogRecordTypeMap.put(recordTypeId, recordTypeName);
    }
}