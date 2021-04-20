@isTest
private class EXT_USR_RQT_ConfigurationCON_TEST {

    static testMethod void myUnitTest() {
    	        
        User testUser = Utils_TestMethods.createStandardUser('tst');
        insert testUser;
				
		Test.startTest();
    	EXT_USR_Config__c config = new EXT_USR_Config__c();
   		config.name = 'Profile test';
   		insert config;
    
        PageReference pageRef = Page.EXT_USR_RQT_Configuration;
        Test.setCurrentPage(pageRef);
        
        EXT_USR_RQT_ConfigurationCON con = new EXT_USR_RQT_ConfigurationCON();
       	con.ExtUsrSettings = config;
        con.validateUsernameEntry('tst@esn.pernod-ricard.com');
        con.enablePwdEncryption();
        con.generateAESKey();
        
        con.userName = 'tst@esn.pernod-ricard.com';
        con.plainPwd = 'totototo';
        
        con.encryptPassword();        
        con.saveConfig();
        
        con.checkPwd ='tatatata';
        
        con.validatePwdEntry();
        con.checkPwd ='totototo';
        con.validatePwdEntry();
        Test.stopTest();
    }
}