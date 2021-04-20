@isTest
private class ASI_eForm_UserIDRequest_AfterUpdateTest
{
    @isTest
    public static void testUserIDRequestAfterUpdate()
    {
       User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);  
    
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
    
      ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequestRemove(userMap);  
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      
      List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
       ASI_eForm_TestClassHelper.createUserIDRequestItem(userIDRequest,userMap,permissionTypeMap);    
      userIDRequest.ASI_eForm_Status__c = 'Final';
      //userIDRequest.ASI_eForm_Sys_User_Permission_Applied__c = false;
      //userIDRequest.ASI_eForm_User_Name__c = currentUser.Id;
      Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile') );

      update userIDRequest;     
    }
}