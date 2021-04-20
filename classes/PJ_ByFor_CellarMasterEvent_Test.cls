@isTest
public class PJ_ByFor_CellarMasterEvent_Test {

    static testmethod void PJ_ByFor_CellarMasterEvent_Test1 () {
        
        Test.startTest();
    
            PageReference pageRef1 = Page.PJ_ByFor_CellarMasterEvent;
            Test.setCurrentPage(pageRef1);
            PJ_ByFor_CellarMasterEvent myPage = new PJ_ByFor_CellarMasterEvent();
        	
            List<PJ_ByFor_Client__c> clientList = PJ_ByFor_TestDataFactory.createClientsWithExp(1,1,'Prospect');
            
            Event[] evt = PJ_ByFor_TestDataFactory.createEvents(2, clientList, 'Confirmed', 'Epernay');
        	
        	ApexPages.currentPage().getParameters().put('eid', evt[0].Id);
        	ApexPages.currentPage().getParameters().put('r','yes');
        
        	myPage.theEvent = evt[0];        
        	
        	System.debug ('######## ' + evt[0].Id);
        	
        
        	myPage.init();

        	ApexPages.currentPage().getParameters().put('r','no');       
        	myPage.init();  

        
        
        	
        	myPage.save(); 
        
            Test.stopTest();
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
}