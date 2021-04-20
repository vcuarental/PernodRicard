@isTest
private class ASI_eForm_UsrIDRqst_EmailControllerTest
{
    @isTest(SeeAllData=true)
    public static void testUserIDRequestEmailController()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);
      
      ASI_eForm_User_ID_Request__c userIdRequest = ASI_eForm_TestClassHelper.createUserIDRequest(userMap);
      ASI_eForm_TestClassHelper.createAttachment(userIdRequest.Id);
      ASI_eForm_TestClassHelper.createNote(userIdRequest.Id);
      
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
                
      ASI_eForm_TestClassHelper.createUserIDRequestItem(userIdRequest,userMap,permissionTypeMap);  
      
      //ASI_eForm_TestClassHelper.executeApprovalProcess(userIdRequest.Id);
      
      ASI_eForm_UserIDRequest_EmailController userIDRequestController = new ASI_eForm_UserIDRequest_EmailController();
      userIDRequestController.request_Id = userIdRequest.Id;
      
      System.assert(userIDRequestController.getItems()!=null, 'Result Status:'+userIDRequestController.getItems());      
      System.assert(userIDRequestController.getRequest()!=null, 'Result Status:'+userIDRequestController.getRequest());
      //System.assert(userIDRequestController.getApprovalHistoryList()!=null, 'Result Status:'+userIDRequestController.getApprovalHistoryList()); 

        
    
    }

    

}