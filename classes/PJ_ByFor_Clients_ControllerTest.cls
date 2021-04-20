@isTest
private class PJ_ByFor_Clients_ControllerTest {
    
    
    static testMethod void testClientTimelineController() {
    	
        // Define the willing environment (page and controller)
        PageReference pageRef = Page.PJ_ByFor_Clients;
        Test.setCurrentPage(pageRef);
        PJ_ByFor_Clients mycontroller = new PJ_ByFor_Clients();
        
        System.debug('## >>> Test data setup   <<< ');
        String status_Client = 'Friend'; 
        PJ_ByFor_Client__c[] contacts = PJ_ByFor_TestDataFactory.createClientsWithExp(100,0, status_Client);
        
        
        
        
        System.debug('## >>> Perform test  <<< ');
        Test.startTest();
        mycontroller.init(); // test the init method
        contacts = mycontroller.getclients();
        
        System.debug('## >>> Calling search methods  <<< ');
		mycontroller.accountNamePrefixParam = 'A'; 
		mycontroller.doSearch();
        mycontroller.getclients();
	
		mycontroller.accountNamePrefixParam = ''; 
		mycontroller.doSearch();
        mycontroller.getclients();
        
        mycontroller.accountNameParam = 'Swan';
        mycontroller.doSearchName();   
        mycontroller.getclients();
        
        
        mycontroller.showParam = '20';
        mycontroller.doSearch();
        mycontroller.getclients();
		        
        System.debug('## >>> calling sort methods  <<< ');
        mycontroller.sortByName(); // Sort by Name
        mycontroller.sortByContactDate(); // Sort by contact date
        //mycontroller.isAsc =true;
        mycontroller.sortByContactDate();        
        mycontroller.sortByCountryOfresidence();
        mycontroller.sortByLastSituationUpdate();
        
        //System.assertEquals(100, contacts.size());
        
        mycontroller.thePageParam = 1;
        mycontroller.companyName = 'EXL-Group';
        
       	Test.stopTest();
    }

    
}