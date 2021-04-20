@isTest
private class ASI_eForm_PRTAFTriggerTest
{
    @isTest
    public static void testPRTAAfterUpdate()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);
      
      ASI_eForm_TestClassHelper.createEmailSetting();
      
      ASI_eForm_Pre_Trip_Approval__c preTripApproval = ASI_eForm_TestClassHelper.createPreTripApproval(userMap);
      
      ASI_eForm_Pre_Trip_Approval__c testInsert = preTripApproval.clone(false, true, false, false);
      testInsert.ASI_eForm_Employee_Traveller__c = null;
      testInsert.ASI_eForm_Position__c = 'testPos';
      testInsert.ASI_eForm_Traveller__c = 'Testtraveller';
      testInsert.ASI_eForm_Traveller_Company__c = 'extTraveller';
      insert testInsert;
      
      preTripApproval.ASI_eForm_Employee_Traveller__c = null;
      preTripApproval.ASI_eForm_Traveller__c = 'test';
      preTripApproval.ASI_eForm_Traveller_Company__c = 'testCompany';
      preTripApproval.ASI_eForm_Company__c = 'test';
      update preTripApproval;
      
      preTripApproval.ASI_eForm_Employee_Traveller__c = userinfo.getuserid();
      preTripApproval.ASI_eForm_Traveller_Company__c = null;
      preTripApproval.ASI_eForm_Traveller__c = null;
      update preTripApproval;
      
      preTripApproval.ASI_eForm_Notify_Travel_Agent__c = true;
      preTripApproval.ASI_eForm_Status__c = 'Final';
           
      List<ASI_eForm_Pre_Trip_Approval_Item__c> preTripItems = ASI_eForm_TestClassHelper.createPreTripApprovalItems(preTripApproval);  
    
      update preTripApproval;    
      
      try {
      
      delete preTripItems;   
      
      } catch (Exception ex)
      {
          System.debug('Trigger Class Exception: ' + ex);
      
      }
        preTripApproval.ASI_eForm_Status__c = 'Draft';
        
        for (ASI_eForm_Pre_Trip_Approval_Item__c pretripitem : preTripItems)
               pretripitem.ASI_eForm_ETD__c = datetime.now().addmonths(-1);
        
        update preTripApproval;
        update preTripItems;
      try {
      
      delete preTripItems;   
      
      } catch (Exception ex)
      {
          System.debug('Trigger Class Exception: ' + ex);
      
      }
          
      try {
      
      delete preTripApproval;
      
      } catch (Exception ex)
      {
          System.debug('Trigger Class Exception: ' + ex);
      
      }  
    
      
    }
}