@isTest
public class PJ_ByFor_CellarMaster_Diary_Test {

      static testmethod void PJ_ByFor_CellarMaster_Diary_Test1 () {
             
          Test.startTest();
    
            PageReference pageRef1 = Page.PJ_ByFor_CellarMaster_Diary;
            Test.setCurrentPage(pageRef1);
            PJ_ByFor_CellarMaster_Diary myPage = new PJ_ByFor_CellarMaster_Diary();          
 			List<PJ_ByFor_Client__c> clientList = PJ_ByFor_TestDataFactory.createClientsWithExp(1,1,'Prospect');
            Event[] evt = PJ_ByFor_TestDataFactory.createEvents(1, clientList, 'Confirmed', 'Epernay');         
          	
          	myPage.currentYear = '';
          
          	myPage.init();
          	myPage.startDateString = Date.today().format();
        	
            PJ_ByFor_Experience__c experience = [select Id, Name, PJ_ByFor_Countries__c, PJ_ByFor_Status__c, CreatedDate, PJ_ByFor_Wishedexperiencedate__c from PJ_ByFor_Experience__c where PJ_ByFor_Client__c=:clientList[0].Id order by CreatedDate desc limit 1];
			System.Debug ('######### Experience ' + experience );

          	myPage.contactId = experience.Id;
          	myPage.choosenContactId = experience.Id;
          	myPage.saveEventToSalesforce();
          	
          
            Test.stopTest();          
          
      }
    
    
}