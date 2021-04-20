@isTest
private class ASI_eForm_ITCRFEmailControllerTest
{
    @isTest (SeeAllData=true)
    public static void testITChangeReqEmailController()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);
      ASI_eForm_TestClassHelper.createRunningNumbers();
      
      ASI_eForm_IT_Change_Request__c  itChangeRequest = ASI_eForm_TestClassHelper.createITChangeRequest(userMap);  
      ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,userMap);
      
      ASI_eForm_TestClassHelper.createAttachment(itChangeRequest.Id);
      ASI_eForm_TestClassHelper.createNote(itChangeRequest.Id);
      
      //ASI_eForm_TestClassHelper.executeApprovalProcess(itChangeRequest.Id);               
       
      ASI_eForm_ITCRFEmailController itChangeReqEmailController =
          new ASI_eForm_ITCRFEmailController();
          
      itChangeReqEmailController.itChangeRequestId =  itChangeRequest.Id;
      
      System.assert(itChangeReqEmailController.getItems()!=null, 'Result Status:'+itChangeReqEmailController.getItems());      
      System.assert(itChangeReqEmailController.getRequest()!=null, 'Result Status:'+itChangeReqEmailController.getRequest());
      //System.assert(itChangeReqEmailController.getApprovalHistoryList()!=null, 'Result Status:'+itChangeReqEmailController.getApprovalHistoryList()); 
      
      
    }


}