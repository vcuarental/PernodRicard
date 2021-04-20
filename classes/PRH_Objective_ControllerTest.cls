/*
    *Created By: Bryan Trinidad
    *Created Date: June 30,2014
    *
    *Description: Test class for PRH_Objective_Controller controller
    *
    *       Updated By:             Date:               Description:        
    *       Bryan Trinidad          July 24, 2014       Change Request: Retrieving objectives based on country dropdown list
    *
*/
@isTest
private class PRH_Objective_ControllerTest {
    
    static testMethod void testOne() {

    	 User u = PRH_TestClass_Utilities.createUser('France','System Administrator');

        PRH_Brand_Criteria__c brandCriteria = PRH_TestClass_Utilities.createBrandCriteria(u,'Luxury Account - Ricard','France');
        
        PRH_Brand_Criteria__c retrieveBrand = [SELECT PRH_Collect__c
                                               FROM PRH_Brand_Criteria__c 
                                               WHERE Id=:brandCriteria.ID];
        
        PRH_Collect__c retrieveColl = [select PRH_Iconic_Account__c from PRH_Collect__c where id=:retrieveBrand.PRH_Collect__c];

        PRH_Luxury_Accounts__c retrieveLuxAcc = [select PRH_Account_Country__c from PRH_Luxury_Accounts__c where id =:retrieveColl.PRH_Iconic_Account__c ];	

        
        System.debug('==> retrieveColl : '+ retrieveColl);
		System.debug('==> retrieveBrand : '+ retrieveBrand);
        system.assertEquals(retrieveLuxAcc.PRH_Account_Country__c,u.Country);

        Test.startTest();
        	system.runAs(u) {
    			PRH_Objective_Controller con = new PRH_Objective_Controller();
                con.selectedCountry = 'France';
                con.rerenderObjectives();
                con.getCountryPicklistValues();
    			con.renderUpdate();

    			//insert objectives
    			con.saveObjects();			
    			con.doCancel();


    		}

    		system.runAs(u) {
    			//load existing objectives
    			PRH_Objective_Controller con = new PRH_Objective_Controller();
                con.selectedCountry = 'France';
                con.rerenderObjectives();
    		}
    	Test.stopTest();
    }


    static testMethod void testTwo() {

    	User u = PRH_TestClass_Utilities.createUser(null,'System Administrator');
        
        PRH_Brand_Criteria__c brandCriteria = PRH_TestClass_Utilities.createBrandCriteria(u,'Luxury Account - Ricard','France');
        
        PRH_Brand_Criteria__c retrieveBrand = [SELECT PRH_Account__r.PRH_Account_Country__c
                                               FROM PRH_Brand_Criteria__c 
                                               WHERE Id=:brandCriteria.Id];

        Test.startTest();
    		system.runAs(u) {

                delete retrieveBrand;

                //load iconic brands when brand criteria is empty
    			PRH_Objective_Controller con = new PRH_Objective_Controller();
                con.selectedCountry = 'France';
                con.rerenderObjectives();

    		}
    	Test.stopTest();
    }

    static testMethod void testThree() {

    	User u = PRH_TestClass_Utilities.createUser('France','System Administrator');        

        List<PRH_Brand_Criteria__c> retrieveBrand = [SELECT Id FROM PRH_Brand_Criteria__c];

        system.assertEquals(retrieveBrand.size(),0);

        Test.startTest();
    		system.runAs(u) {
    			PRH_Objective_Controller con = new PRH_Objective_Controller();
                con.selectedCountry = '--none--';
                con.rerenderObjectives();
    		}
    	Test.stopTest();
    }
}