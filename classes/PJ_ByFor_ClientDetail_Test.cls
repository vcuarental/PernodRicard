@isTest
public class PJ_ByFor_ClientDetail_Test {

    
    static testmethod void PJ_ByFor_ClientDetail_Test1() {
      Group myGroup = [Select Id From Group Where DeveloperName like 'PJ_ByFor_Brand_Company_%' LIMIT 1];
        
      List<GroupMember>gmTest = [select Id from GroupMember where UserOrGroupId=:UserInfo.getUserId() and GroupId=:myGroup.Id];
      if(gmTest.size() == 0)
      {
        GroupMember gm = new GroupMember(UserOrGroupId=UserInfo.getUserId(),GroupId=myGroup.Id);
        insert gm;
      }

      User myUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

      System.runAs(myUser)
      {
    		Test.startTest();  
          
        PJ_ByFor_Client__c client = new PJ_ByFor_Client__c();        
        PageReference pageRef1 = Page.PJ_ByFor_ClientDetail;
        Test.setCurrentPage(pageRef1);        
        List<PJ_ByFor_Client__c> clientList = PJ_ByFor_TestDataFactory.createClientsWithExp(1,1, 'Friend');
        client = clientList[0]; 



        //myPage.client.companyName = 'Test';   
        PJ_ByFor_ClientDetail myPage = new PJ_ByFor_ClientDetail(new ApexPages.StandardController(client));
        myPage.companyName = 'Test';
        myPage.getExperiences();
         
          
          
        Test.stopTest();
      }    
    }    
}