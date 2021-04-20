/*
    *Created By: Bryan Trinidad
    *Created Date: July 15,2014
    *
    *Description: Test class for PRH_TestClass_Utilities
    *
    *       Updated By:             Date:               Description:        
    *       
    *
*/
@isTest(SeeAllData = false) 
private class PRH_TestClass_UtilitiesTest {
    
    static testMethod void test_method_one() {
        
        System.Test.startTest();
             // MODIFIED BY GDT***
            User u = PRH_TestClass_Utilities.createUser('France','System Administrator GDT');
            //PRH_TestClass_Utilities.createCompetitorBrands(u, 'Competitor Brands', 'France');
            PRH_TestClass_Utilities.createBrandCriteria(u,'Luxury Account - Ricard','France');
            
            PRH_TestClass_Utilities.createCompetitorBrands(u, 'Luxury Account - Competitor', 'France');
            

        System.Test.stopTest();
    }
    
}