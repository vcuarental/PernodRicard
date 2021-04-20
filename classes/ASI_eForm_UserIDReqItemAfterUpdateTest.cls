@isTest
private class ASI_eForm_UserIDReqItemAfterUpdateTest
{
  
  @isTest
  public static void testUserIDRequestItemBeforeDelete()
  {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);  
    
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequestChangeProfileWithUserProfile(userMap);  
      List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
       ASI_eForm_TestClassHelper.createUserIDRequestItemSingle(userIDRequest,userMap,permissionTypeMap);    
      
      delete userIDRequestItems;      
  }
  
  @isTest
  public static void testUserIDRequestItemAfterUpdateNewEmployee()
  {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);  
    
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));
      
      ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequest(userMap);  
      List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
       ASI_eForm_TestClassHelper.createUserIDRequestItemComplete(userIDRequest,userMap,permissionTypeMap);  
         
      userIDRequest.ASI_eForm_Status__c = 'Final';
      userIDRequest.ASI_eForm_Sys_User_Permission_Applied__c = false;
      
        List<ASI_eForm_User_ID_Request_Item__c> userReqItems = [SELECT Id, Name, ASI_eForm_IT_Action__c, 
             ASI_eForm_User_ID_Request__c from ASI_eForm_User_ID_Request_Item__c WHERE 
        ASI_eForm_User_ID_Request__c = :userIDRequest.id];
        
        System.debug('XXXX Unit Test Flag 2: ' + userReqItems);
      
      
      System.debug('XXXX userIDRequestItems ' + userReqItems);            
      for (ASI_eForm_User_ID_Request_Item__c userIdRequestItem : userReqItems)
      {
        userIdRequestItem.ASI_eForm_IT_Action__c = 'Complete';      
      }     
      
      update userIDRequest;      
      update userReqItems; 
      
     }
  
  @isTest
  public static void testUserIDRequestItemAfterUpdate()
  {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);  
    
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequest(userMap);  
      List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
       ASI_eForm_TestClassHelper.createUserIDRequestItem(userIDRequest,userMap,permissionTypeMap);    
      userIDRequest.ASI_eForm_Status__c = 'Final';
      userIDRequest.ASI_eForm_Sys_User_Permission_Applied__c = false;         
      
      Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));     
      for (ASI_eForm_User_ID_Request_Item__c userIdRequestItem : userIDRequestItems)
      {
        userIdRequestItem.ASI_eForm_IT_Action__c = 'Complete';      
      }      
      
      update userIDRequest;      
      update userIDRequestItems; 
      
      try {
       userIDRequest.ASI_eForm_User_Alias__c= null;
       update userIDRequest;      
       update userIDRequestItems;
      } catch (Exception ex)
      {
        System.debug('Error: ' + ex);
      }
  }
  
  
  @isTest
  public static void testUserIDRequestItemAfterUpdateChangeProfileFinal()
  {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);  
    
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequestChangeProfileWithUserProfile(userMap);  
      List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
       ASI_eForm_TestClassHelper.createUserIDRequestItemSingle(userIDRequest,userMap,permissionTypeMap);    
      userIDRequest.ASI_eForm_Status__c = 'Draft';
      userIDRequest.ASI_eForm_Sys_User_Permission_Applied__c = false;
      //userIDRequest.ASI_eForm_User_Name__c = currentUser.Id;
      Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));      

      ASI_eForm_User_Profile__c userProfile = userProfileMap.get('userProfile'); 
      userIDRequest.ASI_eForm_User_Profile_Name__c = userProfile.Id;
           
      update userIDRequest;     
      userIDRequest.ASI_eForm_User_Position__c = 'New Position';
      update userIDRequest;      
  }
  
  @isTest
  public static void testUserIDRequestItemAfterUpdateChangeProfile()
  {
      User currentUser = ASI_eForm_TestClassHelper.createUser();
      Map<String,User> userMap = new Map<String,User>();
      userMap.put('owner',currentUser);  
    
      Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);
      Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
      ASI_eForm_User_ID_Request__c  userIDRequest = ASI_eForm_TestClassHelper.createUserIDRequestChangeProfile(userMap);  
      List<ASI_eForm_User_ID_Request_Item__c>  userIDRequestItems = 
       ASI_eForm_TestClassHelper.createUserIDRequestItem(userIDRequest,userMap,permissionTypeMap);    
      userIDRequest.ASI_eForm_Status__c = 'Final';
      userIDRequest.ASI_eForm_Sys_User_Permission_Applied__c = false;
      //userIDRequest.ASI_eForm_User_Name__c = currentUser.Id;
      Map<String, ASI_eForm_User_Profile__c> userProfileMap = ASI_eForm_TestClassHelper.createUserProfile();
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));      
      for (ASI_eForm_User_ID_Request_Item__c userIdRequestItem : userIDRequestItems)
      {
        userIdRequestItem.ASI_eForm_IT_Action__c = 'Complete';      
      }      
      try
      {
       update userIDRequest;      
       update userIDRequestItems; 
      } catch (Exception ex)
      {
        System.debug('Error: ' + ex);
      }
      
      ASI_eForm_TestClassHelper.createSystemPermission(userMap,permissionTypeMap, userProfileMap.get('userProfile'));      
      for (ASI_eForm_User_ID_Request_Item__c userIdRequestItem : userIDRequestItems)
      {
        userIdRequestItem.ASI_eForm_IT_Action__c = 'Invalid Submission';      
      }
      
      update userIDRequestItems; 
      
  }
}