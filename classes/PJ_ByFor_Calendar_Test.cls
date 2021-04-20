@isTest
public class PJ_ByFor_Calendar_Test {

    static testmethod void PJ_ByFor_Calendar_Test1 () {
        
        
             Test.startTest();
    
            PageReference pageRef1 = Page.PJ_ByFor_Calendar;
            Test.setCurrentPage(pageRef1);
            PJ_ByFor_Calendar myPage = new PJ_ByFor_Calendar();
            
        
            List<PJ_ByFor_Client__c> clientList = PJ_ByFor_TestDataFactory.createClientsWithExp(1,1,'Prospect');
            
            Event[] evt = PJ_ByFor_TestDataFactory.createEvents(1, clientList, 'Confirmed', 'Epernay');
            
            System.debug ('######## ' + evt);
            
                
            myPage.makeJsonCalendar();
            myPage.getEvents();
            myPage.init();
            myPage.getEventsListSize();
            
         
            myPage.startDateString = '28/03/2016';
            myPage.endDateString = '28/03/2016';
        
        
            myPage.saveEventToSalesforce();
        
            myPage.startDateString = '28/03/2016';
            myPage.endDateString = '29/03/2016';
        
            myPage.saveEventToSalesforce();
           
            myPage.eventToDelete = evt[0].id;
            myPage.deleteEventToSalesforce();
        

        
            //myPage.saveEventToSalesforce();
            //myPage.startDateString = '2009/01/01';
            //myPage.endDateString = '2009/02/02';
            

    
            Test.stopTest();   
        
        
        
        
        
    }












}