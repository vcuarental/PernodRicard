/*
    *Created By: Bryan Trinidad
    *Created Date: June 30,2014
    *
    *Description: Test class for PRH_BrandCriteria_RelatedList controller
    *
    *       Updated By:             Date:               Description:        
    *       CGI SR					12/28/2016			Modification of core model (add collect) 
    *
*/

@isTest (SeeAllData = false) 
private class PRH_BrandCriteria_RelatedListTest {
    
    	@isTest static void testOne() {
            
		//Creation user
        User u = PRH_TestClass_Utilities.createUser('France','System Administrator');
        
        //Creation Brand Criteria 
         PRH_Brand_Criteria__c brandCriteria = PRH_TestClass_Utilities.createBrandCriteria(u,'Luxury Account - Ricard','France');
     
        //Find Iconic Account    
         PRH_Brand_Criteria__c testBrandCriteria = [Select PRH_Collect__c From PRH_Brand_Criteria__c where PRH_Volume__c=10];
   		 PRH_Collect__c idAccount = [SELECT PRH_Iconic_Account__c FROM PRH_Collect__c WHERE id=:testBrandCriteria.PRH_Collect__c LIMIT 1];
         PRH_Luxury_Accounts__c iconicAccount= [SELECT id FROM PRH_Luxury_Accounts__c WHERE id=:idAccount.PRH_Iconic_Account__c LIMIT 1];
            
        System.Test.startTest();

            system.runAs(u) {
                ApexPages.StandardController std = new ApexPages.StandardController(iconicAccount);
                PRH_BrandCriteria_RelatedList con = new PRH_BrandCriteria_RelatedList(std);

                PRH_Brand_Criteria__c queryBrand = [SELECT Id, PRH_Presence__c 
            										FROM PRH_Brand_Criteria__c 
            										WHERE PRH_Collect__c=:testBrandCriteria.PRH_Collect__c LIMIT 1];
			System.debug('==> queryBrand : '+ queryBrand);
                system.assertEquals(queryBrand.PRH_Presence__c,false);
            }

            system.runAs(u) {
                PRH_BrandCriteria_RelatedList con = new PRH_BrandCriteria_RelatedList();
                con.getgoToIconicAccountPage();
                con.getgoToDashboardPage();
                con.getgoToLeCerclePRPage();
            }

        System.Test.stopTest();

    }
}