@isTest
private class PJ_ByFor_OfferPresentation_Test {

    	static testMethod void testOfferPresentationController() {
    	
       	// Define the willing environment (page and controller)
        PageReference pageRef = Page.PJ_ByFor_OfferPresentation;
        Test.setCurrentPage(pageRef);
            
        PJ_ByFor_Administration__c medium = new PJ_ByFor_Administration__c();
         
            
            
        System.debug('## >>> Test data setup   <<< ');   
        String presentationRT = 'Presentation';
        PJ_ByFor_Administration__c[] presentationList = PJ_ByFor_TestDataFactory.createAdminRessources(3, presentationRT);
        
        String videoRT = 'Video';
        PJ_ByFor_Administration__c[] videoList = PJ_ByFor_TestDataFactory.createAdminRessources(3, videoRT);
        
            
       	//System.assertEquals(3, presentationList.size());
        //System.assertEquals(3, videoList.size());      
            
        System.debug('## >>> Perform test  <<< ');
        Test.startTest();
            
        PJ_ByFor_OfferPresentation mycontroller = new PJ_ByFor_OfferPresentation(new ApexPages.StandardController(medium));
        
        System.debug('## >>> calling media and related attachement methods <<< ');    
        mycontroller.getmedia();
        mycontroller.getAttachments();    
            
        Test.stopTest();
    }
}