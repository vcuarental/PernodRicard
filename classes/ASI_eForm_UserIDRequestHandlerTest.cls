@isTest
private class ASI_eForm_UserIDRequestHandlerTest
{
    
    @isTest
    public static void testUserIDRequestHandler()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);  
    
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequest(userMap);  
      List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
       ASI_eForm_TestClassHelper.createUserIDRequestItem(userIDRequest,userMap,permissionTypeMap);    
      userIDRequest.ASI_eForm_IT_Action__c = 'IT Acknowledged';
      userIDRequest.ASI_eForm_Sys_User_Permission_Applied__c = false;
      
      Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));
      update userIDRequest;
      
    
    }
}