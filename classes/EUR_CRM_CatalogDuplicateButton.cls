/* Controller for VF page that redirects
 * to the appropriate Lightning Component on
 * Product Catalog clone
 * 
 * Usually launched from clone action override
 * 
 * @created 23.07.17
 * @version 1.0
 */
public with sharing class EUR_CRM_CatalogDuplicateButton {
    
    private final EUR_CRM_ProductCatalog__c catalog;
    
    public EUR_CRM_CatalogDuplicateButton(ApexPages.StandardController stdController) {
        this.catalog = (EUR_CRM_ProductCatalog__c)stdController.getRecord();
    }

    public PageReference doClone() {
        return new PageReference('/one/one.app?#/sObject/EUR_CRM_ProductCatalog__c/new?ct=' + catalog.Id);
    }
}