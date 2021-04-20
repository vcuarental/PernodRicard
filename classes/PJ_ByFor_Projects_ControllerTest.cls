@isTest
private class PJ_ByFor_Projects_ControllerTest {

    	static testMethod void testExperienceTimelineController() {
    	
       // Define the willing environment (page and controller)
        PageReference pageRef = Page.PJ_ByFor_Projects;
        Test.setCurrentPage(pageRef);
        PJ_ByFor_Projects mycontroller = new PJ_ByFor_Projects();
        
        
        System.debug('## >>> Test data setup   <<< ');
        String status_Client = 'Friend'; 
        PJ_ByFor_Client__c[] contacts = PJ_ByFor_TestDataFactory.createClientsWithExp(10,10, status_Client);    
        PJ_ByFor_Experience__c[] experienceList = new List<PJ_ByFor_Experience__c>();    
            
        System.debug('## >>> Perform test  <<< ');
        Test.startTest();
        mycontroller.init(); // test the init method    
        experienceList = mycontroller.getProjects();    
        
        System.assertEquals(10, experienceList.size());
            
        System.debug('## >>> Calling search methods  <<< ');
        mycontroller.experienceNameParam = 'Swan';
        mycontroller.doSearch();
        mycontroller.getProjects();     
            
        //Add parameters to page SelectedCountry 
        mycontroller.selectedCountry = 'France';
        mycontroller.getCountries(); 
        mycontroller.doSearch();
        mycontroller.getProjects();     
             
        mycontroller.selectedCountry = 'Epernay';
        mycontroller.getCountries();    
        mycontroller.doSearch();    
        mycontroller.getProjects(); 
            
        mycontroller.experienceNameParam = '';
        mycontroller.doSearch();
        mycontroller.getProjects(); 
            
        mycontroller.getPaginateNav();
        mycontroller.getShowList();    
        mycontroller.getProjects();
        mycontroller.getSize();    

            
        System.debug('## >>> calling sort methods  <<< ');
        mycontroller.sortByExperiences();
        mycontroller.sortByPlace();
        mycontroller.sortByStatus();
        mycontroller.sortByStatus();
        mycontroller.sortByCreationdate();
        mycontroller.sortByDeadline();
            
            
        mycontroller.next();
        Integer var3 = mycontroller.pageNumber;
        mycontroller.previous();
        Boolean var = mycontroller.hasNext;
        Boolean var2 = mycontroller.hasPrevious;
            
        mycontroller.thePageParam = 1;
        mycontroller.navigate();
            
        Test.stopTest();    
    }

}