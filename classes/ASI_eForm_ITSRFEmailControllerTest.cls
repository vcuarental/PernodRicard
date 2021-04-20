@isTest
private class ASI_eForm_ITSRFEmailControllerTest
{
    @isTest(SeeAllData=true)
    public static void testITSRFEmailController()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);
      
      ASI_eForm_IT_Procurement_Service_Request__c itpsr = 
       ASI_eForm_TestClassHelper.createITPSRServiceRequest(userMap);
       
      ASI_eForm_TestClassHelper.createITPSRServiceRequestItem(itpsr);     
      ASI_eForm_TestClassHelper.createAttachment(itpsr.Id);
      ASI_eForm_TestClassHelper.createNote(itpsr.Id);         
      
      //ASI_eForm_TestClassHelper.executeApprovalProcess(itpsr.Id);    
      
      
      ASI_eForm_ITSRFEmailController itsrfEmailController = new 
       ASI_eForm_ITSRFEmailController();
      
      itsrfEmailController.request_Id = itpsr.Id;
      
      System.assert(itsrfEmailController.getItems()!=null, 'Result Status:'+itsrfEmailController.getItems());      
      System.assert(itsrfEmailController.getRequest()!=null, 'Result Status:'+itsrfEmailController.getRequest());
      //System.assert(itsrfEmailController.getApprovalHistoryList()!=null, 'Result Status:'+itsrfEmailController.getApprovalHistoryList()); 
    
    }


}