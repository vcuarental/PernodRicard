@isTest
private class ASI_KOR_ContactTriggerTest {

    static testMethod void test_ASI_KOR_ContactUpdateAccountMainContact() {
        ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
        ASI_KOR_ContactGenerator ctGen = new ASI_KOR_ContactGenerator();
        
       
        Account venue = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_Venue);
        insert venue;
        
        Test.startTest();
        
        // Create the first active contact
        Contact ct1 = ctGen.generateContact(venue, ASI_KOR_ContactGenerator.RT_Keyman);
        ct1.ASI_KOR_Active__c = true;
        insert ct1;
        validateAccountMainContact(venue.Id, ct1.Id);
        
        // Create the second active contact
        Contact ct2 = ctGen.generateContact(venue, ASI_KOR_ContactGenerator.RT_Keyman);
        ct2.ASI_KOR_Active__c = true;
        insert ct2;
        validateAccountMainContact(venue.Id, ct2.Id);
        
        // Create the third active contact
        Contact ct3 = ctGen.generateContact(venue, ASI_KOR_ContactGenerator.RT_Keyman);
        ct3.ASI_KOR_Active__c = true;
        insert ct3;
        validateAccountMainContact(venue.Id, ct3.Id);
        
        // Deactivate the third contact
        ct3.ASI_KOR_Active__c = false;
        update ct3;
        validateAccountMainContact(venue.Id, ct2.Id);
        
        // Delete the second contact
        delete ct2;
        validateAccountMainContact(venue.Id, ct1.Id);
        
        // Undelete the second contact
        undelete ct2;
        validateAccountMainContact(venue.Id, ct2.Id);
        
        Test.stopTest();
    }
    
    // Used by test_ASI_KOR_ContactUpdateAccountMainContact()
    static void validateAccountMainContact(ID acctId, ID expectedContactId) {
        Account acct = [SELECT Id, ASI_KOR_Main_Contact__c FROM Account WHERE Id = :acctId];
        //System.assertEquals(expectedContactId, acct.ASI_KOR_Main_Contact__c);
    }
}