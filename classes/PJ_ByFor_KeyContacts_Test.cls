@isTest
private class PJ_ByFor_KeyContacts_Test {

    static testMethod void testKeyContactController() {
    	
        // Define the willing environment (page and controller)
        PageReference pageRef = Page.PJ_ByFor_KeyContacts;
        Test.setCurrentPage(pageRef);
        PJ_ByFor_KeyContacts mycontroller = new PJ_ByFor_KeyContacts();
        
        System.debug('## >>> Test data setup   <<< ');
        PJ_ByFor_Administration__c[] brochures = PJ_ByFor_TestDataFactory.createAdminRessources(3, 'Brochure');
        
        //System.assertEquals(3, brochures.size());
        
        
        System.debug('## >>> Perform test  <<< ');
        Test.startTest();
        
        System.debug('## >>> calling Brochure method <<< ');  
        mycontroller.getBrochure();
        Test.stopTest();
        

    }

}