/* Test class to check lookup search
 * functionality
 * 
 * @author - PZ - CustomerTimes.Corp
 * @created - 24.07.18
 */
@isTest
private class EUR_CRM_Test_LookupController {
    
    private static final String TEST_OBJ_NAME       = 'EUR_CRM_ProductCatalog__c';
    private static final String TEST_OBJ_SRCH_STR   = 'PLZFINDME';
    
    private static Id init() {
        Type objType = Type.forName(TEST_OBJ_NAME);
        sObject obj = (sObject)objType.newInstance();
        obj.put('Name',TEST_OBJ_SRCH_STR);
        
        SObject cat = EUR_CRM_TestDataFactory.createSObject(obj, true);
        return cat.Id;
    }
    
    private static testMethod void doGetInitial() {
        Id parentId = init();
        
        System.Test.startTest();
        List<sObject> res = EUR_CRM_LookupController.getInitial(TEST_OBJ_NAME,String.valueOf(parentId));
        System.Test.stopTest();
        System.assertEquals(1,res.size(),'Should pull only inserted test object');
        
    }
    private static testMethod void doSearch() {
        Id parentId = init();
        
        System.Test.startTest();
        System.Test.setFixedSearchResults(new List<Id>{parentId}); // SOSL testing fix
        String res = EUR_CRM_LookupController.search(TEST_OBJ_NAME,TEST_OBJ_SRCH_STR,new List<String>{'Id != null'},new List<String>{'LastModifiedDate'});// form dummy clauses for test coverage
        System.Test.stopTest();
        List<List<sObject>> resp = (List<List<sObject>>)JSON.deserialize(res,List<List<sObject>>.class);
        System.assertEquals(1,resp.size(),'Should pull only one type');
        System.assertEquals(1,resp[0].size(),'Should pull only one inserted test record');
        
    }
    private static testMethod void doGetRecents() {
        Id parentId = init();
        
        System.Test.startTest();
        List<SObject> res = EUR_CRM_LookupController.getRecentlyViewed(TEST_OBJ_NAME,new List<String>{'Id != null'},new List<String>{'LastModifiedDate'});// form dummy clauses for test coverage
        System.Test.stopTest();

//        impossible to query recently viewed records during deploy, so assert is always fail on deploy validation
//        System.assertEquals(1,res.size(),'Should pull one recent');
       
    }
}