@isTest
private class ASI_HK_CRM_ContactTriggerTest {

    static testMethod void test_ASI_HK_CRM_ContactUpdateAccountMainContact() {
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_ContactGenerator ctGen = new ASI_HK_CRM_ContactGenerator();
        
        Account acctCredit = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT);
        insert acctCredit;
        
        Test.startTest();
        
        // Create the first active contact
        Contact ct1 = ctGen.generateContact(acctCredit, ASI_HK_CRM_ContactGenerator.RT_Credit);
        ct1.ASI_HK_CRM_Active__c = true;
        insert ct1;
        //validateAccountMainContact(acctCredit.Id, ct1.Id);
        
        // Create the second active contact
        Contact ct2 = ctGen.generateContact(acctCredit, ASI_HK_CRM_ContactGenerator.RT_Credit);
        ct2.ASI_HK_CRM_Active__c = true;
        insert ct2;
        //validateAccountMainContact(acctCredit.Id, ct2.Id);
        
        // Create the third active contact
        Contact ct3 = ctGen.generateContact(acctCredit, ASI_HK_CRM_ContactGenerator.RT_Credit);
        ct3.ASI_HK_CRM_Active__c = true;
        insert ct3;
        //validateAccountMainContact(acctCredit.Id, ct3.Id);
        
        // Deactivate the third contact
        ct3.ASI_HK_CRM_Active__c = false;
        update ct3;
        //validateAccountMainContact(acctCredit.Id, ct2.Id);
        
        // Delete the second contact
        delete ct2;
        //validateAccountMainContact(acctCredit.Id, ct1.Id);
        
        // Undelete the second contact
        undelete ct2;
        //validateAccountMainContact(acctCredit.Id, ct2.Id);
        
        Test.stopTest();
    }
    
    // Used by test_ASI_HK_CRM_ContactUpdateAccountMainContact()
    /*
    static void validateAccountMainContact(ID acctId, ID expectedContactId) {
        Account acct = [SELECT Id, ASI_HK_CRM_Main_Contact__c FROM Account WHERE Id = :acctId];
        System.assertEquals(expectedContactId, acct.ASI_HK_CRM_Main_Contact__c);
    }
    */
}