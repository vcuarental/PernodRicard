/**
 * Created by Andrii Leshchuk on 20.02.2019.
 */

public with sharing class EUR_CRM_ProductCatalogItemTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void beforeInsert() {
        this.prepopulateExternalId(Trigger.new);
    }

    override protected void afterInsert() {
        new EUR_CRM_ProductCatalogItemRollUpServ().updateParentsRollUpFields(Trigger.new);
    }

    override protected void afterUpdate() {
        new EUR_CRM_ProductCatalogItemRollUpServ().updateParentsRollUpFields(Trigger.new, (Map<Id, EUR_CRM_ProductCatalogItem__c>) Trigger.oldMap);
    }

    override protected void afterDelete() {
        new EUR_CRM_ProductCatalogItemRollUpServ().updateParentsRollUpFields(Trigger.old);
    }

    override protected void afterUndelete() {
        new EUR_CRM_ProductCatalogItemRollUpServ().updateParentsRollUpFields(Trigger.new);
    }



    private void prepopulateExternalId(List<EUR_CRM_ProductCatalogItem__c> productCatalogItems) {
        System.debug('EUR_CRM_ProductCatalogItemTriggerHandler running');
        Map<Id, List<EUR_CRM_ProductCatalogItem__c>> productCatalogItemMap = this.generateProductCatalogItemMap(productCatalogItems);
        Map<Id, EUR_CRM_ProductCatalog__c> productCatalogMap = new Map<Id, EUR_CRM_ProductCatalog__c>([
                SELECT Id, EUR_CRM_ParentProductCatalogID__c, RecordType.Name, EUR_CRM_External_ID__c, EUR_CRM_IsStandard__c
                FROM EUR_CRM_ProductCatalog__c
                WHERE Id IN :productCatalogItemMap.keySet()
        ]);

        /**
        * Prepopulate EUR_CRM_External_ID__c field in EUR_CRM_ProductCatalogItem__c
        * */
        for (Id productCatalogId : productCatalogItemMap.keySet()) {
            EUR_CRM_ProductCatalog__c productCatalog = productCatalogMap.get(productCatalogId);
            if (this.isProductCatalogIsValid(productCatalog)) {
                List<EUR_CRM_ProductCatalogItem__c> productCatalogItemsTemp = productCatalogItemMap.get(productCatalogId);
                for (EUR_CRM_ProductCatalogItem__c productCatalogItem: productCatalogItemsTemp) {
                    if (productCatalog.EUR_CRM_External_ID__c == null) {
                        productCatalogItem.EUR_CRM_External_ID__c = productCatalogItem.EUR_CRM_ProductMN__c;
                    } else {
                        productCatalogItem.EUR_CRM_External_ID__c = productCatalog.EUR_CRM_External_ID__c + '-' + productCatalogItem.EUR_CRM_ProductMN__c;
                    }
                    }
            }
        }
    }

    private Map<Id, List<EUR_CRM_ProductCatalogItem__c>> generateProductCatalogItemMap(List<EUR_CRM_ProductCatalogItem__c> productCatalogItems) {
        Map<Id, List<EUR_CRM_ProductCatalogItem__c>> productCatalogItemMap = new Map<Id, List<EUR_CRM_ProductCatalogItem__c>>();
        for (EUR_CRM_ProductCatalogItem__c productCatalogItem : productCatalogItems) {
            this.addValueToProductCatalogItemMap(productCatalogItemMap, productCatalogItem);
        }

        return productCatalogItemMap;
    }

    private void addValueToProductCatalogItemMap(Map<Id, List<EUR_CRM_ProductCatalogItem__c>> productCatalogItemsMap, EUR_CRM_ProductCatalogItem__c productCatalogItem) {
        if (!productCatalogItemsMap.containsKey(productCatalogItem.EUR_CRM_PriceBookID__c)) {
            productCatalogItemsMap.put(productCatalogItem.EUR_CRM_PriceBookID__c, new List<EUR_CRM_ProductCatalogItem__c>());
        }
        productCatalogItemsMap.get(productCatalogItem.EUR_CRM_PriceBookID__c).add(productCatalogItem);
    }

    private Boolean isProductCatalogIsValid(EUR_CRM_ProductCatalog__c productCatalog) {
        return productCatalog.RecordType.Name == 'Indirect'
                || productCatalog.RecordType.Name == 'POSM'
//                || (productCatalog.RecordType.Name == 'Direct' && productCatalog.EUR_CRM_IsStandard__c);
                || (productCatalog.RecordType.Name == 'Direct' /*&& ( ! productCatalog.EUR_CRM_IsStandard__c)*/);
    }
}