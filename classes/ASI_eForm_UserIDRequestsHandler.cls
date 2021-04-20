public class ASI_eForm_UserIDRequestsHandler 
{ 
   public static void processUserIdApproveEmail(Map<Id,Set<Id>> userIdRequestExemptMap, 
         Map<Id,ASI_eForm_User_ID_Request__c> triggerNewMap)
    {
        EmailTemplate emailTemplate =  [SELECT id,name FROM EmailTemplate WHERE 
        Name in ('ASI eForm UIDR Final Approved Email Template (HK)') LIMIT 1];    
        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();  
        
        List<ASI_eForm_User_ID_Request_Item__c> userIdRequestItems = 
        [Select Id, ASI_eForm_IT_Handle_By__c, ASI_eForm_PR_System__c, ASI_eForm_User_ID_Request__c
         from ASI_eForm_User_ID_Request_Item__c
         WHERE ASI_eForm_User_ID_Request__c in :userIdRequestExemptMap.keySet()];
        
        Set<Id> associatedUserIds = new Set<Id>();
        List<Id> associatedSystemIds= new List<Id>();
        
        Map<Id,List<ASI_eForm_User_ID_Request_Item__c>> userIdRequestsChildMapping
        = new Map<Id,List<ASI_eForm_User_ID_Request_Item__c>>();
                 
        
        for (ASI_eForm_User_ID_Request_Item__c userIdRequestItem : userIdRequestItems)
        {
            if (userIdRequestItem.ASI_eForm_IT_Handle_By__c != null)
            {
                associatedUserIds.add(userIdRequestItem .ASI_eForm_IT_Handle_By__c);
            }   
            
            associatedSystemIds.add(userIdRequestItem.ASI_eForm_PR_System__c);        
            if (userIdRequestsChildMapping.containsKey(userIdRequestItem.ASI_eForm_User_ID_Request__c ))            
            {
               userIdRequestsChildMapping.get(userIdRequestItem.ASI_eForm_User_ID_Request__c).add(userIdRequestItem);    
            } else {
               List<ASI_eForm_User_ID_Request_Item__c>  userIdRequestList  = new List<ASI_eForm_User_ID_Request_Item__c>();
               userIdRequestList.add(userIdRequestItem);  
               userIdRequestsChildMapping.put(userIdRequestItem.ASI_eForm_User_ID_Request__c,userIdRequestList);
            }
        }        
        
        List<ASI_eForm_PR_System__c> sytemItems = [SELECT Id,
        ASI_eForm_Responsible_By_1__c,ASI_eForm_Responsible_By_2__c,ASI_eForm_Responsible_By_3__c,
        ASI_eForm_Responsible_By_4__c,ASI_eForm_Responsible_By_5__c,ASI_eForm_Responsible_By_6__c,
        ASI_eForm_Responsible_By_7__c,ASI_eForm_Responsible_By_8__c,ASI_eForm_Responsible_By_9__c,
        ASI_eForm_Responsible_By_10__c
        from ASI_eForm_PR_System__c where id in :associatedSystemIds];
        
        
        //Context ID List<Users>
        Map<Id,Set<Id>> systemEmailMapping = new Map<Id,Set<Id>>();
        //Map<Id,Set<String>> contextExternalEmailMapping = new Map<Id,Set<String>>();
       
       for (ASI_eForm_PR_System__c systemItem : sytemItems )
       {
          Set<Id> systemUserIds = new Set<Id>();          
          //Set<String> contextExternalUserEmails = new Set<String>();
                       
          if (systemItem.ASI_eForm_Responsible_By_1__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_1__c);
          }    
          if (systemItem.ASI_eForm_Responsible_By_2__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_2__c);
          }    
          if (systemItem.ASI_eForm_Responsible_By_3__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_3__c);
          }    
          if (systemItem.ASI_eForm_Responsible_By_4__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_4__c);
          }
          if (systemItem.ASI_eForm_Responsible_By_5__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_5__c);
          }
          if (systemItem.ASI_eForm_Responsible_By_6__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_6__c);
          }
          if (systemItem.ASI_eForm_Responsible_By_7__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_7__c);
          }
          if (systemItem.ASI_eForm_Responsible_By_8__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_8__c);
          }
          if (systemItem.ASI_eForm_Responsible_By_9__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_9__c);
          }
          if (systemItem.ASI_eForm_Responsible_By_10__c!=null)
          {
              systemUserIds.add(systemItem.ASI_eForm_Responsible_By_10__c);
          }    
          
          systemEmailMapping.put(systemItem.Id, systemUserIds);          
          //contextExternalEmailMapping.put(context.Id, contextExternalUserEmails);          
          associatedUserIds.addAll(systemUserIds);
       }
        
       Map<Id,User> selectedUsersMap = new Map<Id,User>([Select Id, Email from User where Id in :associatedUserIds]);
        OrgWideEmailAddress itServiceDesk = ASI_eForm_GenericTriggerClass.retrieveITServiceDesk();
        for (Id userIdRequestId : userIdRequestExemptMap.keySet())
        {
           ASI_eForm_User_ID_Request__c   userIdRequest = triggerNewMap.get(userIdRequestId);
           
           List<ASI_eForm_User_ID_Request_Item__c> userIdRequestItemList = userIdRequestsChildMapping.get(userIdRequestId);
           
           Set<String> uniqueUserEmails = new Set<String>(); 
           Set<Id> userExceptionIDs = userIdRequestExemptMap.get(userIdRequestId);
                            
            for (ASI_eForm_User_ID_Request_Item__c userIdRequestItem : userIdRequestItemList)
            {
                 if (userIdRequestItem.ASI_eForm_IT_Handle_By__c != null)
                 {
                     if (!userExceptionIDs.contains(userIdRequestItem.ASI_eForm_IT_Handle_By__c)) 
                     {
                         uniqueUserEmails.add(selectedUsersMap.get(userIdRequestItem.ASI_eForm_IT_Handle_By__c).Email);
                     }
                 }    
                 
                 Set<Id> userIds = systemEmailMapping.get(userIdRequestItem.ASI_eForm_PR_System__c);             
                 //Set<String> externalUserEmails = contextExternalEmailMapping.get(itChangeRequestItem.ASI_eForm_Context__c);
                 //uniqueExternalUserEmails.addAll(externalUserEmails);
                 
                 for (Id userId : userIds)
                 {
                     if (!userExceptionIDs.contains(userId)) 
                     {  
                         uniqueUserEmails.add(selectedUsersMap.get(userId).Email);
                     }
                 }
            }
            List<String> addresses = new List<String>();
            List<String> externalAddresses = new List<String>();
            addresses.addAll(uniqueUserEmails);
            //externalAddresses.addAll(uniqueExternalUserEmails); 
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(userIdRequest.ownerId);
            
            if (itServiceDesk != null)
            {
                email.setSenderDisplayName(itServiceDesk.DisplayName);
                email.setReplyTo(itServiceDesk.Address);
            }
            
            email.setToAddresses(addresses);
            email.setWhatId(userIdRequest.Id);
            email.setTemplateId(emailTemplate.Id);
            //email.setCCAddresses(externalAddresses);    
            allMail.add(email);                        
        }    
        Messaging.SendEmailResult [] r = Messaging.sendEmail(allMail);  
    }
    
    //Before Update And Insert
    public static void processUserIdChangeUserProfile(List<ASI_eForm_User_ID_Request__c> userIdChangeUserProfiles, 
                      Map<Id,ASI_eForm_User_ID_Request__c> userIdChangeUserProfileOldMap)
    {
        Set<Id> userProfileIds = new Set<Id>();
        Set<Id> userRequestIds = new Set<Id>();       
        for (ASI_eForm_User_ID_Request__c  userIdRequest : userIdChangeUserProfiles)
        {
            ASI_eForm_User_ID_Request__c  userIdRequestOld = null;
            
            if (userIdRequest.Id != null)
            {
                userIdRequestOld =  userIdChangeUserProfileOldMap.get(userIdRequest.Id);
            }

            if ((userIdRequestOld == null && userIdRequest.ASI_eForm_User_Profile_Name__c != null) ||
            ( userIdRequest.ASI_eForm_User_Profile_Name__c != null && userIdRequest.ASI_eForm_User_Profile_Name__c != userIdRequestOld.ASI_eForm_User_Profile_Name__c))
            {
                userProfileIds.add(userIdRequest.ASI_eForm_User_Profile_Name__c);   
                if (userIdRequest.Id != null)
                {
                 userRequestIds.add(userIdRequest.Id);         
                } 
            }           
        }
        
        if (userProfileIds.size()>0)
        {     
          populateUserProfiles(userProfileIds,userIdChangeUserProfiles,userRequestIds);
        } 
    
    }
    
    public static void populateUserProfiles(Set<Id> userProfileIds, List<ASI_eForm_User_ID_Request__c> userIdChangeUserProfiles, Set<Id> userRequestIds)
    {
        Map<Id,ASI_eForm_User_Profile__c> userProfileMap = new Map<Id,ASI_eForm_User_Profile__c>([SELECT ASI_eForm_First_Name__c,ASI_eForm_Last_Name__c,
        ASI_eForm_Line_Manager__c, ASI_eForm_Service_Period_From__c, ASI_eForm_Service_Period_To__c, ASI_eForm_User_Company__c,
        ASI_eForm_User_Country__c, ASI_eForm_User_Department__c, ASI_eForm_User_Position__c, ASI_eForm_User_Alias__c, ASI_eForm_Service_Account__c,
        ASI_eForm_Ownership_Email__c FROM ASI_eForm_User_Profile__c
        Where Id in :userProfileIds]);
        
        
        List<AggregateResult> hasDeleteUserIdRequestItem = [Select ASI_eForm_User_ID_Request__c from ASI_eForm_User_ID_Request_Item__c
        WHERE ASI_eForm_User_ID_Request__c in :userIdChangeUserProfiles 
        AND ASI_eForm_Permission_Action__c = 'Delete Permission'        
        Group by ASI_eForm_User_ID_Request__c
        ]; 
        
        Set<Id> hasDeleteItemUserIds = new Set<Id>();
        
        for(AggregateResult hasDeleteItemUserId : hasDeleteUserIdRequestItem)
        {
            hasDeleteItemUserIds.add((Id)hasDeleteItemUserId.get('ASI_eForm_User_ID_Request__c')); 
        }
        
        for (ASI_eForm_User_ID_Request__c  userIdRequest :  userIdChangeUserProfiles)
        {
          if (userIdRequest.Id == null)
          {
                ASI_eForm_User_Profile__c userProfile =  userProfileMap.get(userIdRequest.ASI_eForm_User_Profile_Name__c);
                if (userIdRequest.ASI_eForm_First_Name__c == null || ''.equals(userIdRequest.ASI_eForm_First_Name__c.trim()))
                {
                    userIdRequest.ASI_eForm_First_Name__c = userProfile.ASI_eForm_First_Name__c;            
                }                      
                if (userIdRequest.ASI_eForm_Last_Name__c== null || ''.equals(userIdRequest.ASI_eForm_Last_Name__c.trim()))
                {
                    userIdRequest.ASI_eForm_Last_Name__c= userProfile.ASI_eForm_Last_Name__c;            
                }                     
                if (userIdRequest.ASI_eForm_Line_Manager__c== null)
                {
                    userIdRequest.ASI_eForm_Line_Manager__c= userProfile.ASI_eForm_Line_Manager__c;            
                }
                if (userIdRequest.ASI_eForm_Service_Period_From__c== null)
                {
                    userIdRequest.ASI_eForm_Service_Period_From__c= userProfile.ASI_eForm_Service_Period_From__c;            
                }
                if (userIdRequest.ASI_eForm_Service_Period_To__c== null)
                {
                    userIdRequest.ASI_eForm_Service_Period_To__c= userProfile.ASI_eForm_Service_Period_To__c;            
                }
                if (userIdRequest.ASI_eForm_User_Company__c== null || ''.equals(userIdRequest.ASI_eForm_User_Company__c.trim()))
                {
                    userIdRequest.ASI_eForm_User_Company__c= userProfile.ASI_eForm_User_Company__c;            
                }
                if (userIdRequest.ASI_eForm_User_Country__c== null || ''.equals(userIdRequest.ASI_eForm_User_Country__c.trim()))
                {
                    userIdRequest.ASI_eForm_User_Country__c= userProfile.ASI_eForm_User_Country__c;            
                }
                if (userIdRequest.ASI_eForm_Service_Account__c != userProfile.ASI_eForm_Service_Account__c)
                {
                    userIdRequest.ASI_eForm_Service_Account__c= userProfile.ASI_eForm_Service_Account__c;            
                }
                if (userIdRequest.ASI_eForm_PR_Email__c== null || ''.equals(userIdRequest.ASI_eForm_PR_Email__c.trim()))
                {
                    userIdRequest.ASI_eForm_PR_Email__c= userProfile.ASI_eForm_Ownership_Email__c;            
                }
                if (userIdRequest.ASI_eForm_User_Department__c== null || ''.equals(userIdRequest.ASI_eForm_User_Department__c.trim()))
                {
                    userIdRequest.ASI_eForm_User_Department__c= userProfile.ASI_eForm_User_Department__c;            
                } 
                if (userIdRequest.ASI_eForm_User_Position__c== null || ''.equals(userIdRequest.ASI_eForm_User_Position__c.trim()))
                {
                    userIdRequest.ASI_eForm_User_Position__c= userProfile.ASI_eForm_User_Position__c;            
                }
                if (userIdRequest.ASI_eForm_User_Alias__c== null || ''.equals(userIdRequest.ASI_eForm_User_Alias__c.trim()))
                {
                    userIdRequest.ASI_eForm_User_Alias__c= userProfile.ASI_eForm_User_Alias__c;            
                }            
            } else if (hasDeleteItemUserIds.contains(userIdRequest.Id))
            {
              userIdRequest.addError('Unable to Change Profile User. Please Delete User ID Request Item Associated with Previous Change Profile User.');                             
            } else {
             
             ASI_eForm_User_Profile__c userProfile =  userProfileMap.get(userIdRequest.ASI_eForm_User_Profile_Name__c);
             userIdRequest.ASI_eForm_First_Name__c = userProfile.ASI_eForm_First_Name__c;            
             userIdRequest.ASI_eForm_Last_Name__c= userProfile.ASI_eForm_Last_Name__c;            
             userIdRequest.ASI_eForm_Line_Manager__c= userProfile.ASI_eForm_Line_Manager__c;            
             userIdRequest.ASI_eForm_Service_Period_From__c= userProfile.ASI_eForm_Service_Period_From__c;            
             userIdRequest.ASI_eForm_Service_Period_To__c= userProfile.ASI_eForm_Service_Period_To__c;            
             userIdRequest.ASI_eForm_User_Company__c= userProfile.ASI_eForm_User_Company__c;            
             userIdRequest.ASI_eForm_First_Name__c = userProfile.ASI_eForm_First_Name__c;            
             userIdRequest.ASI_eForm_User_Country__c= userProfile.ASI_eForm_User_Country__c;
             userIdRequest.ASI_eForm_Service_Account__c= userProfile.ASI_eForm_Service_Account__c;  
             userIdRequest.ASI_eForm_PR_Email__c= userProfile.ASI_eForm_Ownership_Email__c;           
             userIdRequest.ASI_eForm_User_Department__c= userProfile.ASI_eForm_User_Department__c;            
             userIdRequest.ASI_eForm_User_Position__c= userProfile.ASI_eForm_User_Position__c;
             userIdRequest.ASI_eForm_User_Alias__c= userProfile.ASI_eForm_User_Alias__c;
            }                
        }  
    }
    
    public static void processUserIdChangeProfile(Map<Id,ASI_eForm_User_ID_Request__c> userIdChangeProfileMap)
    {
       Map<Id,ASI_eForm_User_Profile__c> userProfileMap = new Map<Id,ASI_eForm_User_Profile__c>([SELECT ASI_eForm_First_Name__c,ASI_eForm_Last_Name__c,
        ASI_eForm_Line_Manager__c, ASI_eForm_Service_Period_From__c, ASI_eForm_Service_Period_To__c, 
        ASI_eForm_User_Company__c, ASI_eForm_User_Alias__c,
        ASI_eForm_User_Country__c, ASI_eForm_Service_Account__c, ASI_eForm_Ownership_Email__c, ASI_eForm_User_Department__c, ASI_eForm_User_Position__c
        FROM ASI_eForm_User_Profile__c
        Where Id in :userIdChangeProfileMap.keySet()]);     
        
        Set<Id> changedUserIDRequests = new Set<Id>();
        Set<Id> equalUserIDRequests = new Set<Id>();
        
        for (ASI_eForm_User_Profile__c userProfile : userProfileMap.values())
        {
          
          ASI_eForm_User_ID_Request__c userIdRequest = userIdChangeProfileMap.get(userProfile.Id);
            
          if ((userIdRequest.ASI_eForm_First_Name__c==null && userProfile.ASI_eForm_First_Name__c!=null) || (userIdRequest.ASI_eForm_First_Name__c != null 
          && !userIdRequest.ASI_eForm_First_Name__c.equals(userProfile.ASI_eForm_First_Name__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if ((userIdRequest.ASI_eForm_Last_Name__c==null && userProfile.ASI_eForm_Last_Name__c!=null) ||
           (userIdRequest.ASI_eForm_Last_Name__c!= null 
          && !userIdRequest.ASI_eForm_Last_Name__c.equals(userProfile.ASI_eForm_Last_Name__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if((userIdRequest.ASI_eForm_Line_Manager__c==null && userProfile.ASI_eForm_Line_Manager__c!=null) ||
           (userIdRequest.ASI_eForm_Line_Manager__c!= null 
          && !userIdRequest.ASI_eForm_Line_Manager__c.equals(userProfile.ASI_eForm_Line_Manager__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          }  else if((userIdRequest.ASI_eForm_Service_Period_From__c==null && userProfile.ASI_eForm_Service_Period_From__c!=null) ||
           (userIdRequest.ASI_eForm_Service_Period_From__c != null 
          && userIdRequest.ASI_eForm_Service_Period_From__c != userProfile.ASI_eForm_Service_Period_From__c))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if ((userIdRequest.ASI_eForm_Service_Period_To__c==null && userProfile.ASI_eForm_Service_Period_To__c!=null) ||
          (userIdRequest.ASI_eForm_Service_Period_To__c  != null 
          && userIdRequest.ASI_eForm_Service_Period_To__c  != userProfile.ASI_eForm_Service_Period_To__c))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if((userIdRequest.ASI_eForm_User_Company__c==null && userProfile.ASI_eForm_User_Company__c!=null) ||
           (userIdRequest.ASI_eForm_User_Company__c!= null 
          && !userIdRequest.ASI_eForm_User_Company__c.equals(userProfile.ASI_eForm_User_Company__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if((userIdRequest.ASI_eForm_User_Country__c==null && userProfile.ASI_eForm_User_Country__c!=null) ||
           (userIdRequest.ASI_eForm_User_Country__c!= null 
          && !userIdRequest.ASI_eForm_User_Country__c.equals(userProfile.ASI_eForm_User_Country__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          }
          else if((userIdRequest.ASI_eForm_PR_Email__c==null && userProfile.ASI_eForm_Ownership_Email__c!=null) ||
           (userIdRequest.ASI_eForm_PR_Email__c!= null 
          && !userIdRequest.ASI_eForm_PR_Email__c.equals(userProfile.ASI_eForm_Ownership_Email__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          }
          else if(userIdRequest.ASI_eForm_Service_Account__c != userProfile.ASI_eForm_Service_Account__c)
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if((userIdRequest.ASI_eForm_User_Department__c==null && userProfile.ASI_eForm_User_Department__c!=null) ||
           (userIdRequest.ASI_eForm_User_Department__c!= null 
          && !userIdRequest.ASI_eForm_User_Department__c.equals(userProfile.ASI_eForm_User_Department__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if((userIdRequest.ASI_eForm_User_Position__c==null && userProfile.ASI_eForm_User_Position__c!=null) ||
           (userIdRequest.ASI_eForm_User_Position__c!= null 
          && !userIdRequest.ASI_eForm_User_Position__c.equals(userProfile.ASI_eForm_User_Position__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else if((userIdRequest.ASI_eForm_User_Alias__c==null && userProfile.ASI_eForm_User_Alias__c!=null) ||
           (userIdRequest.ASI_eForm_User_Alias__c!= null 
          && !userIdRequest.ASI_eForm_User_Alias__c.equals(userProfile.ASI_eForm_User_Alias__c)))
          {
            changedUserIDRequests.add(userIdRequest.Id);            
          } else
          {
           equalUserIDRequests.add(userIdRequest.Id);
          }         
       }
       
        if (equalUserIDRequests.size()>0)
       {
           List<ASI_eForm_User_ID_Request_Item__c> userIdRequestItems = 
           [SELECT Id, ASI_eForm_IT_Action__c from ASI_eForm_User_ID_Request_Item__c where ASI_eForm_PR_System__r.Name = 'Active Directory User Profile' 
            and ASI_eForm_User_ID_Request__c in :equalUserIDRequests];            
            
           if (userIdRequestItems.size()>0)
           {
             //Issue #5 20140908: Only allow delete item which are not complete
             List<ASI_eForm_User_ID_Request_Item__c> allowedUIDItemDelete = new List<ASI_eForm_User_ID_Request_Item__c>();
             for(ASI_eForm_User_ID_Request_Item__c uidItem : userIdRequestItems)
             {
                 if(uidItem.ASI_eForm_IT_Action__c !=  'Complete')
                 {
                     allowedUIDItemDelete.add(uidItem);
                 }
             }
             if(allowedUIDItemDelete.size() > 0)
                 delete allowedUIDItemDelete;
             //20140908: End of change
           } 
       }            
       
       if (changedUserIDRequests.size()>0)
       {
           List<ASI_eForm_User_ID_Request_Item__c> userIdRequestItems = 
           [SELECT Id,ASI_eForm_User_ID_Request__c from ASI_eForm_User_ID_Request_Item__c where ASI_eForm_PR_System__r.Name = 'Active Directory User Profile' 
            and ASI_eForm_User_ID_Request__c in :changedUserIDRequests];            
        
           List<ASI_eForm_User_ID_Request_Item__c>  newUserIdRequestItems = new List<ASI_eForm_User_ID_Request_Item__c>();
           
           RecordType userRequestIdItemRecordType = [Select Id from RecordType 
           Where sObjectType='ASI_eForm_User_ID_Request_Item__c' 
           and DeveloperName='ASI_eForm_User_ID_Request_Item' LIMIT 1];
           
           for (ASI_eForm_User_ID_Request_Item__c userIdRequestItem : userIdRequestItems)
           {
             if (changedUserIDRequests.contains(userIdRequestItem.ASI_eForm_User_ID_Request__c))
             {
               changedUserIDRequests.remove(userIdRequestItem.ASI_eForm_User_ID_Request__c);
             }
           }          
           
           if (changedUserIDRequests.size() > 0)
           {
             List<ASI_eForm_Permission_Type__c> permissionTypeList = [Select Id, ASI_eForm_PR_System__c from ASI_eForm_Permission_Type__c
            where ASI_eForm_PR_System__r.Name = 'Active Directory User Profile'
            and Name = 'Default' LIMIT 1
            ];
            //if (permissionTypeList.size() == 0)
            //{
            //  userProfile.addError('No Permission Type found for the Active Directory User Profile. Please Review Data');
            //}
             ASI_eForm_Permission_Type__c permissionType =  permissionTypeList == null ? null : permissionTypeList.get(0);
               
               for (Id userId : changedUserIDRequests)
               {
                   ASI_eForm_User_ID_Request_Item__c  newUserIdRequestItem = new ASI_eForm_User_ID_Request_Item__c();
                   newUserIdRequestItem.ASI_eForm_Permission_Action__c = 'Change User Profile';
                   newUserIdRequestItem.ASI_eForm_Permission_TypeN__c = permissionType.Id;
                   newUserIdRequestItem.ASI_eForm_PR_System__c = permissionType.ASI_eForm_PR_System__c;
                   newUserIdRequestItem.ASI_eForm_User_ID_Request__c = userId;
                   newUserIdRequestItem.RecordTypeId = userRequestIdItemRecordType.Id;
                   newUserIdRequestItems.add(newUserIdRequestItem);
               }
           } 
           
           if (newUserIdRequestItems.size() > 0)
           {
             insert newUserIdRequestItems;
           }
       }
    }
        
    public static void processUserIdRequestComplete(Map<Id,ASI_eForm_User_ID_Request__c> userIdRequestFinalComplete)
    {     
        
        Map<Id,Id> userRequestIdAndUserProfileMap = new Map<Id,Id>();
        /*
        Map<Id,ASI_eForm_User_ID_Request__c> userRequestIdMap = new Map<Id,ASI_eForm_User_ID_Request__c>();
        */
        
        Map<Id,RecordType> newEmployeeRecordType =
          new Map<Id,RecordType>([SELECT Id from RecordType 
          WHERE SobjectType='ASI_eForm_User_ID_Request__c' and DeveloperName like '%New_Employee%']);
        
        Map<Id,RecordType> removeEmployeeRecordType =
          new Map<Id,RecordType>([SELECT Id from RecordType 
          WHERE SobjectType='ASI_eForm_User_ID_Request__c' and DeveloperName like '%Remove%']);  
          
        Map<Id,ASI_eForm_User_Profile__c> userIdProfileIdMapping = new Map<Id,ASI_eForm_User_Profile__c>();
            
        
        for (ASI_eForm_User_ID_Request__c userRequest : userIdRequestFinalComplete.values())
        {
          //ASI_eForm_User_ID_Request__c userRequest = (ASI_eForm_User_ID_Request__c) userRequestObject;       
          //userRequest.ASI_eForm_Sys_User_Permission_Applied__c  = true;
          //userRequestIdMap.put(userRequest.Id,userRequest);             
          if (newEmployeeRecordType.containsKey(userRequest.RecordTypeId))
          {
               ASI_eForm_User_Profile__c userProfile = new ASI_eForm_User_Profile__c();
               userProfile.ASI_eForm_First_Name__c = userRequest.ASI_eForm_First_Name__c;
               userProfile.ASI_eForm_Last_Name__c = userRequest.ASI_eForm_Last_Name__c;
               userProfile.ASI_eForm_Line_Manager__c = userRequest.ASI_eForm_Line_Manager__c;
               userProfile.ASI_eForm_Service_Period_From__c = userRequest.ASI_eForm_Service_Period_From__c;
               userProfile.ASI_eForm_Service_Period_To__c = userRequest.ASI_eForm_Service_Period_To__c;
               userProfile.ASI_eForm_User_Company__c = userRequest.ASI_eForm_User_Company__c;
               userProfile.ASI_eForm_User_Country__c = userRequest.ASI_eForm_User_Country__c;
               userProfile.ASI_eForm_Service_Account__c= userRequest.ASI_eForm_Service_Account__c; 
               userProfile.ASI_eForm_Ownership_Email__c= userRequest.ASI_eForm_PR_Email__c; 
               userProfile.ASI_eForm_User_Department__c = userRequest.ASI_eForm_User_Department__c;
               userProfile.ASI_eForm_User_Position__c = userRequest.ASI_eForm_User_Position__c;
               userProfile.ASI_eForm_User_Alias__c = userRequest.ASI_eForm_User_Alias__c;
               userIdProfileIdMapping.put(userRequest.Id,userProfile);
          } else
          {
               userRequestIdAndUserProfileMap.put(userRequest.Id,userRequest.ASI_eForm_User_Profile_Name__c);                 
          }
        }      
         
        Map<Id,ASI_eForm_User_Profile__c> userProfileMap = new Map<Id,ASI_eForm_User_Profile__c>([SELECT ASI_eForm_First_Name__c,ASI_eForm_Last_Name__c,
        ASI_eForm_Line_Manager__c, ASI_eForm_Service_Period_From__c, ASI_eForm_Service_Period_To__c, ASI_eForm_User_Company__c,
        ASI_eForm_User_Country__c, ASI_eForm_Service_Account__c, ASI_eForm_Ownership_Email__c, ASI_eForm_User_Department__c, ASI_eForm_User_Position__c FROM ASI_eForm_User_Profile__c
        Where Id in :userRequestIdAndUserProfileMap.values()]); 
            
        for (Id  userRequestId :  userRequestIdAndUserProfileMap.keySet())
        {
            ASI_eForm_User_ID_Request__c  userRequest = userIdRequestFinalComplete.get(userRequestId);            
            ASI_eForm_User_Profile__c userProfile =  userProfileMap.get(userRequest.ASI_eForm_User_Profile_Name__c);            
            userProfile.ASI_eForm_First_Name__c = userRequest.ASI_eForm_First_Name__c; 
            userProfile.ASI_eForm_Last_Name__c = userRequest.ASI_eForm_Last_Name__c;            
            userProfile.ASI_eForm_Line_Manager__c = userRequest.ASI_eForm_Line_Manager__c;            
            userProfile.ASI_eForm_Service_Period_From__c = userRequest.ASI_eForm_Service_Period_From__c;            
            userProfile.ASI_eForm_Service_Period_To__c = userRequest.ASI_eForm_Service_Period_To__c;            
            userProfile.ASI_eForm_User_Company__c = userRequest.ASI_eForm_User_Company__c;            
            userProfile.ASI_eForm_User_Position__c= userRequest.ASI_eForm_User_Position__c;            
            userProfile.ASI_eForm_User_Country__c = userRequest.ASI_eForm_User_Country__c;  
            userProfile.ASI_eForm_Service_Account__c= userRequest.ASI_eForm_Service_Account__c;    
            userProfile.ASI_eForm_Ownership_Email__c= userRequest.ASI_eForm_PR_Email__c;        
            userProfile.ASI_eForm_User_Department__c = userRequest.ASI_eForm_User_Department__c;            
            userProfile.ASI_eForm_User_Alias__c= userRequest.ASI_eForm_User_Alias__c;
            if (removeEmployeeRecordType.containsKey(userRequest.RecordTypeId))
            {
                userProfile.ASI_eForm_Active__c = false;
            }
            userIdProfileIdMapping.put(userRequest.Id,userProfile);
        }     
        
        //permissionsToBeApplied
        List<ASI_eForm_User_ID_Request_Item__c> permissionsToBeApplied = [SELECT 
        Id, 
        ASI_eForm_User_ID_Request__r.RecordTypeId,
        ASI_eForm_User_ID_Request__r.Id, 
        ASI_eForm_User_ID_Request__r.ASI_eForm_User_Profile_Name__c,
        ASI_eForm_Permission_Action__c,
        ASI_eForm_PR_System__c, 
        ASI_eForm_Permission_TypeN__c,
        ASI_eForm_BO_Additional_Remarks__c  
        from ASI_eForm_User_ID_Request_Item__c 
        where ASI_eForm_User_ID_Request__c in :userIdRequestFinalComplete.keySet()];
                        
        //currentUserPermission
        List<ASI_eForm_User_System_Permission__c> userPermissions = [SELECT 
        Id, 
        ASI_eForm_PR_System__c, 
        ASI_eForm_Permission_TypeN__c, 
        ASI_eForm_User_Profile_Name__c,
        ASI_eForm_BO_Additional_Remarks__c
        from ASI_eForm_User_System_Permission__c 
        where ASI_eForm_User_Profile_Name__c in :userRequestIdAndUserProfileMap.values()];
        
        Map<String,ASI_eForm_User_System_Permission__c> userPermissionsMap = 
        new Map<String,ASI_eForm_User_System_Permission__c>();
        
        for(ASI_eForm_User_System_Permission__c userSystemPermission : userPermissions)
        {
            String key = '' + userSystemPermission.ASI_eForm_User_Profile_Name__c  
            + userSystemPermission.ASI_eForm_PR_System__c 
            + userSystemPermission.ASI_eForm_Permission_TypeN__c
            + userSystemPermission.ASI_eForm_BO_Additional_Remarks__c;              
        
            userPermissionsMap.put(key, userSystemPermission);
        }
        
        List<ASI_eForm_User_System_Permission__c> permissionsToBeAdded = 
        new List<ASI_eForm_User_System_Permission__c>();
        
        List<ASI_eForm_User_System_Permission__c> permissionsToBeDeleted = 
        new List<ASI_eForm_User_System_Permission__c>();           
        
        upsert userIdProfileIdMapping.values();
            
        for(ASI_eForm_User_ID_Request_Item__c permissionToBeApplied : permissionsToBeApplied)
        {
            
            Id userProfileId = null;
                    
            if (newEmployeeRecordType.containsKey(permissionToBeApplied.ASI_eForm_User_ID_Request__r.RecordTypeId))
            {
                userProfileId = userIdProfileIdMapping.get(permissionToBeApplied.ASI_eForm_User_ID_Request__c).Id;
            } else
            {
               userProfileId = permissionToBeApplied.ASI_eForm_User_ID_Request__r.ASI_eForm_User_Profile_Name__c;
            }
            
            String key = '' + userProfileId 
            + permissionToBeApplied.ASI_eForm_PR_System__c 
            + permissionToBeApplied.ASI_eForm_Permission_TypeN__c
            + permissionToBeApplied.ASI_eForm_BO_Additional_Remarks__c;           

            if ('Add Permission' == permissionToBeApplied.ASI_eForm_Permission_Action__c)
            {
                if (!userPermissionsMap.containsKey(key))
                {
                    ASI_eForm_User_System_Permission__c permissionToBeAdded = new ASI_eForm_User_System_Permission__c();
                    permissionToBeAdded.ASI_eForm_User_Profile_Name__c  = userProfileId ; 
                    permissionToBeAdded.ASI_eForm_PR_System__c = permissionToBeApplied.ASI_eForm_PR_System__c;
                    permissionToBeAdded.ASI_eForm_Permission_TypeN__c = permissionToBeApplied.ASI_eForm_Permission_TypeN__c;          
                    permissionToBeAdded.ASI_eForm_BO_Additional_Remarks__c = permissionToBeApplied.ASI_eForm_BO_Additional_Remarks__c;
                    permissionsToBeAdded.add(permissionToBeAdded);                
                } else {
                    ASI_eForm_User_System_Permission__c permissionToBeAdded = userPermissionsMap.get(key);  
                    permissionToBeAdded.ASI_eForm_BO_Additional_Remarks__c = permissionToBeApplied.ASI_eForm_BO_Additional_Remarks__c;
                    permissionsToBeAdded.add(permissionToBeAdded);                    
                }          
            } else if ('Delete Permission' == permissionToBeApplied.ASI_eForm_Permission_Action__c)
            {
                
                ASI_eForm_User_System_Permission__c permissionToBeDeleted = userPermissionsMap.get(key);
                if (permissionToBeDeleted  != null)
                {
                    permissionsToBeDeleted.add(permissionToBeDeleted);                
                }            
            }                 
        }
        
        upsert permissionsToBeAdded;
        delete permissionsToBeDeleted;
        //update userRequestIdMap.values();
    }

}