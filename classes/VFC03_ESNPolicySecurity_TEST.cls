@isTest
private class VFC03_ESNPolicySecurity_TEST {

    static testMethod void testESNAdminController() {
    
        User testUser = Utils_TestMethods.createStandardUser('tst');
        insert testUser;
        
        
    
        Organization org = [Select id from Organization][0];
        ESNPolicySecurity__c config = new ESNPolicySecurity__c();
        config.name = 'Profile WS';
        insert config;
    
    
        PageReference pageRef = Page.VFP03_ESNSecAdmin;
        Test.setCurrentPage(pageRef);
        
        VFC03_ESNPolicySecurity c = new VFC03_ESNPolicySecurity();
        
        c.validateUsernameEntry('tst@esn.pernod-ricard.com');
        
        c.generateAESKey();
        
        c.userName = 'tst@esn.pernod-ricard.com';
        c.plainPwd ='totototo';
        
        c.encryptPassword();
        
        c.saveConfig();
        
        c.checkPwd ='tatatata';
        
        c.validatePwdEntry();
        c.checkPwd ='totototo';
        c.validatePwdEntry();
        
    }
}