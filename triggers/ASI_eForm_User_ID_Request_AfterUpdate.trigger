trigger ASI_eForm_User_ID_Request_AfterUpdate on ASI_eForm_User_ID_Request__c (after update) {

    Map<Id,Set<Id>> userIdRequestExemptMap = new Map<Id,Set<Id>>();
    Map<Id,ASI_eForm_User_ID_Request__c> userIdRequestFinalComplete = new Map<Id,ASI_eForm_User_ID_Request__c>();
    Map<Id,ASI_eForm_User_ID_Request__c> userIdChangeProfileMap = new Map<Id,ASI_eForm_User_ID_Request__c>();
    
    for (ASI_eForm_User_ID_Request__c  userIdRequest : Trigger.new)
    {
        if (userIdRequest.ASI_eForm_Status__c=='Final' 
        /*&&  (userIdRequest.ASI_eForm_IT_Action__c == null || userIdRequest.ASI_eForm_IT_Action__c == '')*/ &&
        (userIdRequest.ASI_eForm_Status__c != trigger.oldMap.get(userIdRequest.id).ASI_eForm_Status__c ))
        {
            Set<Id> userExceptionIDs = new Set<Id>();
            userIdRequestExemptMap.put(userIdRequest.Id,userExceptionIDs );
            
            if (userIdRequest.ASI_eForm_HR_Business_Department_Manager__c != null)
            {
                userExceptionIDs.add(userIdRequest.ASI_eForm_HR_Business_Department_Manager__c);
            }
            if (userIdRequest.ASI_eForm_Preview_Approver__c != null)
            {
                userExceptionIDs.add(userIdRequest.ASI_eForm_Preview_Approver__c);
            }        
            if (userIdRequest.ASI_eForm_User_Profile_Name__c != null)
            {
              userIdChangeProfileMap.put(userIdRequest.ASI_eForm_User_Profile_Name__c,userIdRequest);            
            }
            
        } else if (userIdRequest.ASI_eForm_Status__c=='Draft') 
        {
          if (userIdRequest.ASI_eForm_User_Profile_Name__c != null)
          {
            userIdChangeProfileMap.put(userIdRequest.ASI_eForm_User_Profile_Name__c,userIdRequest);            
          }
        } else if (userIdRequest.ASI_eForm_Status__c=='Final' 
        &&   userIdRequest.ASI_eForm_IT_Action__c=='Complete')
        {
            userIdRequestFinalComplete.put(userIdRequest.Id,userIdRequest);        
        }
    }
    
    
    if (userIdChangeProfileMap.size() > 0)
    {
        ASI_eForm_UserIDRequestsHandler.processUserIdChangeProfile(userIdChangeProfileMap);
    }
    
    if (userIdRequestExemptMap.size() > 0)
    {
        ASI_eForm_UserIDRequestsHandler.processUserIdApproveEmail(userIdRequestExemptMap,Trigger.newMap);
    }
    
    if (userIdRequestFinalComplete.size() > 0)
    {
       ASI_eForm_UserIDRequestsHandler.processUserIdRequestComplete(userIdRequestFinalComplete); 
    }
    
            ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_User_ID_Request__Share', 
                                                                    'ASI_eForm_User_Request_Manager_Access__c', 
                                                                    new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_HR_Business_Department_Manager__c'}, 
                                                                    trigger.oldMap);
    
}