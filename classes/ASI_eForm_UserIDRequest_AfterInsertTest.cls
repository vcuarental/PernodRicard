@isTest
private class ASI_eForm_UserIDRequest_AfterInsertTest
{
    @isTest
    public static void testUserIDRequestAfterInsert()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);      
            
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      
      ASI_eForm_User_ID_Request__c userIdRequest = ASI_eForm_TestClassHelper.createUserIDRequest(userMap);
      ASI_eForm_TestClassHelper.createUserIDRequestItem(userIdRequest,userMap,permissionTypeMap);
    }
    
    @isTest
    public static void testUserIDRequestAfterInsertRemove()
    {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);      
      
      Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
      
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));
      ASI_eForm_User_ID_Request__c userIdRequest = ASI_eForm_TestClassHelper.createUserIDRequestRemove(userMap);
      //ASI_eForm_TestClassHelper.createUserIDRequestItem(userIdRequest,userMap,permissionTypeMap);
    }
}