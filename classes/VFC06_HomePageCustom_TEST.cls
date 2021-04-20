@isTest
private class VFC06_HomePageCustom_TEST {

    static testMethod void myUnitTest() {
    	/* Create 3 users */
    	// User French
    	User userFR = TestFactory.createStandardUser('userFR');
    	userFR.LanguageLocaleKey = 'fr';
    	userFR.ESNPolicyAcceptanceDate__c = Date.today()-15; 	//this user logged into salesforce for the first time 16 days ago.
    	userFR.TECH_Connection_Today__c = null; 	// this user is logging into salesforce. he should not view the home page.
    	insert userFR;
    	
    	// User English
    	User userEN = TestFactory.createStandardUser('userEN');
    	userEN.LanguageLocaleKey = 'en_US';
    	userEN.ESNPolicyAcceptanceDate__c = Date.today()-15; 	// this user logged into salesforce for the first time 16 days ago.
    	userEN.TECH_Connection_Today__c = Datetime.now(); 		// this user clicked on the Home tab button. He was already logged today.
    	insert userEN;
    	
    	// User Spanish
    	User userES = TestFactory.createStandardUser('userES');
    	userES.LanguageLocaleKey = 'es';
    	userES.ESNPolicyAcceptanceDate__c = Date.today(); //this user log into salesforce for the first time.
    	insert userES;
    	
    	/* Create new instance of Visualforce Page */
    	Pagereference VFP06 = Page.VFP06_HomePageCustom;
    	Test.setCurrentPageReference(VFP06);
        VFC06_HomePageCustom con = new VFC06_HomePageCustom();
        
    	// Access the page as a French User
    	System.runas(userFR){   
        	con.checkTimeElapsed();	         	
    	}
        
    	// Access the page as a English User
    	System.runas(userEN){   
        	con.checkTimeElapsed();	         	
    	}
    	
    	// Access the page as a Spanish User
    	System.runas(userES){   
        	con.checkTimeElapsed();	         	
    	}
    }
}