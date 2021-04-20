trigger ASI_eForm_User_ID_Request_AfterInsert on ASI_eForm_User_ID_Request__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {    
    
    Id userRequestItemRecordType ; 
    
    set<id> t= Global_RecordTypeCache.getRtIdSet('ASI_eForm_User_ID_Request_Item__c',new Set<String>{'ASI_eForm_User_ID_Request_Item'});
    if(t.size()>0)
        userRequestItemRecordType =new List<Id> (t)[0];
       
    Set<id> removeRequestID=Global_RecordTypeCache.getRtIdSet('ASI_eForm_User_ID_Request__c',new Set<String>{'ASI_eForm_HK_Remove_ID','ASI_eForm_CN_Remove_ID'});
    
    Set<id> changeRequestID=Global_RecordTypeCache.getRtIdSet('ASI_eForm_User_ID_Request__c',new Set<String>{'ASI_eForm_HK_Change_Profile','ASI_eForm_CN_Change_Profile'});
    
    List<ASI_eForm_PR_System__c> basicSelectionSystems = [SELECT ID
    from ASI_eForm_PR_System__c where ASI_eForm_Basic_Selection__c = true]; 
    List<ASI_eForm_User_ID_Request_Item__c> userRequestItems = new List<ASI_eForm_User_ID_Request_Item__c>();
    //UserIdToBeRemove, UserRequestId
    Map<Id,Id> userRequestsForRemoval =  new Map<Id,Id>(); 
    
    List<ASI_eForm_Permission_Type__c> basicSelectionPermissionTypes
    = [SELECT ASI_eForm_PR_System__c, Id from ASI_eForm_Permission_Type__c
       where ASI_eForm_PR_System__r.ASI_eForm_Basic_Selection__c = true Order by ASI_eForm_PR_System__c];
    
    Map<Id,List<ASI_eForm_Permission_Type__c>> basicSelectionPermissionTypeMap = new Map<Id,List<ASI_eForm_Permission_Type__c>>();
    
    for (ASI_eForm_Permission_Type__c permissionType : basicSelectionPermissionTypes)
    {
       if (!basicSelectionPermissionTypeMap.containsKey(permissionType.ASI_eForm_PR_System__c))
       {
           List<ASI_eForm_Permission_Type__c> permissionTypes = new List<ASI_eForm_Permission_Type__c>();
           permissionTypes.add(permissionType);
           basicSelectionPermissionTypeMap.put(permissionType.ASI_eForm_PR_System__c,permissionTypes); 
       } else
       {
           basicSelectionPermissionTypeMap.get(permissionType.ASI_eForm_PR_System__c).add(permissionType);
       }
    }
    
    for(ASI_eForm_User_ID_Request__c userRequest: Trigger.new) {    
    
      if (removeRequestID.contains(userRequest.RecordTypeid))
      {
          userRequestsForRemoval.put(userRequest.ASI_eForm_User_Profile_Name__c,userRequest.Id); 
      }else if(!changeRequestID.contains(userRequest.RecordTypeid))   {
          for (Id prSystemId : basicSelectionPermissionTypeMap.keySet() )
          {
             List<ASI_eForm_Permission_Type__c> permissionTypes = basicSelectionPermissionTypeMap.get(prSystemId);
             ASI_eForm_User_ID_Request_Item__c userRequestItem = new ASI_eForm_User_ID_Request_Item__c();
             userRequestItem.ASI_eForm_Permission_Action__c = 'Add Permission';
             userRequestItem.ASI_eForm_PR_System__c = prSystemId;
             userRequestItem.ASI_eForm_User_ID_Request__c = userRequest.id;
             if (permissionTypes.size() == 1)
             {
              userRequestItem.ASI_eForm_Permission_TypeN__c = permissionTypes.get(0).Id;
             } 
             userRequestItem.RecordTypeId = userRequestItemRecordType;
             System.debug('userRequestItemRecordType='+userRequestItemRecordType);
             userRequestItems.add(userRequestItem);     
          }
      }
    }
         
    List<ASI_eForm_User_System_Permission__c> userSystemPermissionsToBeDeleted = [select  ASI_eForm_PR_System__c, 
    ASI_eForm_Permission_TypeN__c,ASI_eForm_User_Profile_Name__c,ASI_eForm_BO_Additional_Remarks__c from ASI_eForm_User_System_Permission__c 
    where ASI_eForm_User_Profile_Name__c in :userRequestsForRemoval.keySet()];
    
    for(ASI_eForm_User_System_Permission__c userSystemPermissionToBeDeleted : userSystemPermissionsToBeDeleted ) {
         ASI_eForm_User_ID_Request_Item__c userRequestItem = new ASI_eForm_User_ID_Request_Item__c();
         userRequestItem.ASI_eForm_Permission_Action__c = 'Delete Permission';
         userRequestItem.ASI_eForm_PR_System__c = userSystemPermissionToBeDeleted.ASI_eForm_PR_System__c;
         userRequestItem.ASI_eForm_User_ID_Request__c = userRequestsForRemoval.get(userSystemPermissionToBeDeleted.ASI_eForm_User_Profile_Name__c);
         userRequestItem.ASI_eForm_Permission_TypeN__c  = userSystemPermissionToBeDeleted.ASI_eForm_Permission_TypeN__c;
         userRequestItem.ASI_eForm_BO_Additional_Remarks__c = userSystemPermissionToBeDeleted.ASI_eForm_BO_Additional_Remarks__c;
         userRequestItem.RecordTypeId = userRequestItemRecordType;         
         userRequestItems.add(userRequestItem);     
    }
    
    if (userRequestItems.size() > 0) {
        insert userRequestItems;
    }
     
    ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_User_ID_Request__Share', 
                                                            'ASI_eForm_User_Request_Manager_Access__c', 
                                                            new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_HR_Business_Department_Manager__c'}, 
                                                            null);
          
  }
}