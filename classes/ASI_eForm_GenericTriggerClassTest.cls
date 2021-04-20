@isTest
private class ASI_eForm_GenericTriggerClassTest
{
    @isTest   
    public static void testGenericTriggerClass()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
       ASI_eForm_User_ID_Request__c  userIdRequest =  ASI_eForm_TestClassHelper.createUserIDRequest(userMap);
       //ASI_eForm_TestClassHelper.createUserIDRequest(userMap);   
       Map<String,ASI_eForm_PR_System__c> systemMap = ASI_eForm_TestClassHelper.createSystem(userMap);   
       Map<String,ASI_eForm_Permission_Type__c> permissionTypeMap = ASI_eForm_TestClassHelper.createSystemPermissionType(systemMap);
                 
       ASI_eForm_TestClassHelper.createUserIDRequestItem(userIdRequest,userMap,permissionTypeMap);
       
       userIdRequest.ASI_eForm_Status__c  = 'Final'; 
       
       update userIdRequest;
       
       try {
       
        delete userIdRequest;
       
       } catch (DmlException e) {
            //Assert Error Message
            System.assert(e.getMessage().contains(Label.ASI_eForm_Not_Allowed_To_Delete_Record), 
                e.getMessage());
       }         
    
    }
   
      @isTest   
    public static void testITChangeRequestBeforeDeleteCN()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createRunningNumbers();
        
       ASI_eForm_IT_Change_Request__c itChangeRequest =  ASI_eForm_TestClassHelper.createITChangeRequestCN(userMap);    
       itChangeRequest.ASI_eForm_Status__c  = 'Final'; 
       List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequestItems = 
        ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,userMap);
       update itChangeRequest;
     
       System.RunAs(user){  
       try {
       
     
        
       
        delete itChangeRequest;
       
       } catch (DmlException e) {
            //Assert Error Message
            System.assert(e.getMessage().contains(Label.ASI_eForm_Not_Allowed_To_Delete_Record), 
                e.getMessage());
       }         
       }
       
       try {
       
        delete itChangeRequestItems;
       
       } catch (DmlException e) {
            //Assert Error Message
            /*
            System.assert(e.getMessage().contains(Label.ASI_eForm_Not_Allowed_To_Delete_Record), 
                e.getMessage()); */
       }
    
    }
   
        
    @isTest   
    public static void testITChangeRequestBeforeDelete()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createRunningNumbers();
        
       ASI_eForm_IT_Change_Request__c itChangeRequest =  ASI_eForm_TestClassHelper.createITChangeRequest(userMap);    
       itChangeRequest.ASI_eForm_Status__c  = 'Final'; 
       List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequestItems = 
        ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,userMap);
       update itChangeRequest;
     
       System.RunAs(user){  
       try {
       
     
        
       
        delete itChangeRequest;
       
       } catch (DmlException e) {
            //Assert Error Message
            System.assert(e.getMessage().contains(Label.ASI_eForm_Not_Allowed_To_Delete_Record), 
                e.getMessage());
       }         
       }
       
       try {
       
        delete itChangeRequestItems;
       
       } catch (DmlException e) {
            //Assert Error Message
            System.assert(e.getMessage().contains(Label.ASI_eForm_Not_Allowed_To_Delete_Record), 
                e.getMessage());
       }
    
    }
    
    @isTest   
    public static void testITChangeRequestItemBeforeDelete()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createRunningNumbers();
        
       ASI_eForm_IT_Change_Request__c itChangeRequest =  ASI_eForm_TestClassHelper.createITChangeRequest(userMap);    

       List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequestItems = 
        ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,userMap);

       
        delete itChangeRequestItems;
      
    }
    
    @isTest   
    public static void testITChangeRequestCompleteToAcknowledged()
    {
        User user = ASI_eForm_TestClassHelper.createUser();
        Map<String,User> userMap = new Map<String,User>();
        userMap.put('owner',user);
        
        ASI_eForm_TestClassHelper.createRunningNumbers();
        
       ASI_eForm_IT_Change_Request__c itChangeRequest =  ASI_eForm_TestClassHelper.createITChangeRequest(userMap);    
       itChangeRequest.ASI_eForm_Status__c  = 'Final'; 
       //itChangeRequest.ASI_eForm_IT_Action__c = 'Complete';
       List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequestItems = 
        ASI_eForm_TestClassHelper.createITChangeRequestItems(itChangeRequest,userMap);
       update itChangeRequest;
       List<ASI_eForm_IT_Change_Request_Item__c> itemsToUpdate = new List<ASI_eForm_IT_Change_Request_Item__c>();
       for (ASI_eForm_IT_Change_Request_Item__c i : itChangeRequestItems)
       {
           i.ASI_eForm_IT_Action__c = 'Complete';
           itemsToUpdate.add(i);
       }
       
       update itemsToUpdate;
       
       System.RunAs(user){  
       try {
       
           for (ASI_eForm_IT_Change_Request_Item__c i : itemsToUpdate)
           {
               i.ASI_eForm_IT_Action__c = 'IT Acknowledged';
           }
           update itemsToUpdate;
       
       } catch (DmlException e) {
       }         
       }
    
    }


}