/* Test class for check catalog clone
 * action override redirect logic
 * 
 */
@isTest
private class EUR_CRM_Test_CatalogDuplicateButton {
    // will influence testing user region and product record types
    private static final String TEST_REGION     = 'NL';
    /* ========================================================
     *                  TEST DATA CREATION
     * 
     * ========================================================*/
    private static EUR_CRM_ProductCatalog__c init(){
        EUR_CRM_ProductCatalog__c cat = new EUR_CRM_ProductCatalog__c(
            Name = 'Test Catalog'
            ,EUR_CRM_IsStandard__c = false
            ,EUR_CRM_IsManual__c = false
            ,EUR_CRM_Country__c = TEST_REGION
        );

        cat = (EUR_CRM_ProductCatalog__c)EUR_CRM_TestDataFactory.createSObject(cat,true);
        return cat;
    }   
    
    /* ========================================================
     *                  TEST CASES
     * 
     * ========================================================*/
    /* Assert controller extension redirects properly with a list of valid parameters
     * 
     */
    static testMethod void doRedirectClone() {
        EUR_CRM_ProductCatalog__c cat = init();
        System.Test.startTest();
        
        PageReference pr = Page.EUR_CRM_DuplicateCatalog;
        System.Test.setCurrentPage(pr);
        ApexPages.StandardController catCtrl = new ApexPages.StandardController(cat);
        EUR_CRM_CatalogDuplicateButton ext  = new EUR_CRM_CatalogDuplicateButton(catCtrl);
        PageReference redirect = ext.doClone();
        System.Test.stopTest();
        
        System.assertNotEquals(null,redirect,'Should redirect');
        // lightning uri naming workaround to pull parameters
        PageReference pfg = new PageReference(redirect.getAnchor());
        Map<String,String> params = pfg.getParameters();
        System.assertNotEquals(true,params.isEmpty(),'Should have parameters');
        System.assertEquals(cat.Id,params.get('ct'),'Should redirect to target catalog');
        
    }
}