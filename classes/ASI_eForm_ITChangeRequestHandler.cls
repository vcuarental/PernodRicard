public class ASI_eForm_ITChangeRequestHandler
{
  
   public static void processITChangeRequest(Map<Id,Set<Id>> itChangeRequestUserIdExemptMap, Map<Id,ASI_eForm_IT_Change_Request__c> itChangeRequestMap)
   {
        EmailTemplate emailTemplate =  [SELECT id,name FROM EmailTemplate WHERE 
        Name in ('ASI eForm ITCRF Approved Email Template (HK)') LIMIT 1];    
        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();  
        
        List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequestItems = 
        [Select Id, ASI_eForm_Context__c, ASI_eForm_IT_Handle_By__c, ASI_eForm_IT_Change_Request__c
         from ASI_eForm_IT_Change_Request_Item__c
         WHERE ASI_eForm_IT_Change_Request__c in :itChangeRequestUserIdExemptMap.keySet()];
        
        Set<Id> associatedUserIds = new Set<Id>();
        List<Id> associatedContextIds= new List<Id>();
        
        Map<Id,List<ASI_eForm_IT_Change_Request_Item__c>> itChangeReqAndChildMapping
        = new Map<Id,List<ASI_eForm_IT_Change_Request_Item__c>>();
                 
        
        for (ASI_eForm_IT_Change_Request_Item__c itChangeRequestItem : itChangeRequestItems)
        {
            if (itChangeRequestItem.ASI_eForm_IT_Handle_By__c != null)
            {
                associatedUserIds.add(itChangeRequestItem.ASI_eForm_IT_Handle_By__c);
            }   
            
            associatedContextIds.add(itChangeRequestItem.ASI_eForm_Context__c);        
            if (itChangeReqAndChildMapping.containsKey(itChangeRequestItem.ASI_eForm_IT_Change_Request__c))            
            {
               itChangeReqAndChildMapping.get(itChangeRequestItem.ASI_eForm_IT_Change_Request__c).add(itChangeRequestItem);    
            } else {
               List<ASI_eForm_IT_Change_Request_Item__c>  itChangeRequestItemList  = new List<ASI_eForm_IT_Change_Request_Item__c>();
               itChangeRequestItemList.add(itChangeRequestItem);  
               itChangeReqAndChildMapping.put(itChangeRequestItem.ASI_eForm_IT_Change_Request__c,itChangeRequestItemList);
            }
        }        
        
        List<ASI_eForm_Context__c> contextItems = [SELECT ASI_eForm_External_Email_1__c, ASI_eForm_External_Email_2__c,
        ASI_eForm_Responsible_By_1__c,ASI_eForm_Responsible_By_2__c,ASI_eForm_Responsible_By_3__c,
        ASI_eForm_Responsible_By_4__c,ASI_eForm_Responsible_By_5__c,ASI_eForm_Responsible_By_6__c,
        ASI_eForm_Responsible_By_7__c,ASI_eForm_Responsible_By_8__c,ASI_eForm_Responsible_By_9__c,
        ASI_eForm_Responsible_By_10__c
        from ASI_eForm_Context__c where id in :associatedContextIds];
        
        
        //Context ID List<Users>
        Map<Id,Set<Id>> contextEmailMapping = new Map<Id,Set<Id>>();
        Map<Id,Set<String>> contextExternalEmailMapping = new Map<Id,Set<String>>();
       
       for (ASI_eForm_Context__c context : contextItems)
       {
          Set<Id> contextUserIds = new Set<Id>();          
          Set<String> contextExternalUserEmails = new Set<String>();
          
          if (context.ASI_eForm_External_Email_1__c !=null)
          {
              contextExternalUserEmails.add(context.ASI_eForm_External_Email_1__c);
          }
          if (context.ASI_eForm_External_Email_2__c!=null)
          {
              contextExternalUserEmails.add(context.ASI_eForm_External_Email_2__c);
          }    
          if (context.ASI_eForm_Responsible_By_1__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_1__c);
          }    
          if (context.ASI_eForm_Responsible_By_2__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_2__c);
          }    
          if (context.ASI_eForm_Responsible_By_3__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_3__c);
          }    
          if (context.ASI_eForm_Responsible_By_4__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_4__c);
          }
          if (context.ASI_eForm_Responsible_By_5__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_5__c);
          }
          if (context.ASI_eForm_Responsible_By_6__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_6__c);
          }
          if (context.ASI_eForm_Responsible_By_7__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_7__c);
          }
          if (context.ASI_eForm_Responsible_By_8__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_8__c);
          }
          if (context.ASI_eForm_Responsible_By_9__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_9__c);
          }
          if (context.ASI_eForm_Responsible_By_10__c!=null)
          {
              contextUserIds.add(context.ASI_eForm_Responsible_By_10__c);
          }    
          
          contextEmailMapping.put(context.Id, contextUserIds);          
          contextExternalEmailMapping.put(context.Id, contextExternalUserEmails);          
          associatedUserIds.addAll(contextUserIds);
       }
        
       Map<Id,User> selectedUsersMap = new Map<Id,User>([Select Id, Email from User where Id in :associatedUserIds]);
        OrgWideEmailAddress itServiceDesk = ASI_eForm_GenericTriggerClass.retrieveITServiceDesk();
        for (Id itChangeRequestId : itChangeRequestUserIdExemptMap.keySet())
        {
           ASI_eForm_IT_Change_Request__c itChangeRequest = itChangeRequestMap.get(itChangeRequestId);
           List<ASI_eForm_IT_Change_Request_Item__c> itChangeRequestItemList = itChangeReqAndChildMapping.get(itChangeRequestId);
           Set<String> uniqueUserEmails = new Set<String>(); 
           Set<Id> userExceptionIDs = itChangeRequestUserIdExemptMap.get(itChangeRequestId);
           Set<String> uniqueExternalUserEmails = new Set<String>();
                            
            for (ASI_eForm_IT_Change_Request_Item__c itChangeRequestItem : itChangeRequestItemList)
            {
                 if (itChangeRequestItem.ASI_eForm_IT_Handle_By__c != null)
                 {
                     if (!userExceptionIDs.contains(itChangeRequestItem.ASI_eForm_IT_Handle_By__c)) 
                     {
                         uniqueUserEmails.add(selectedUsersMap.get(itChangeRequestItem.ASI_eForm_IT_Handle_By__c).Email);
                     }
                 }    
                 Set<Id> userIds = contextEmailMapping.get(itChangeRequestItem.ASI_eForm_Context__c);
                 Set<String> externalUserEmails = contextExternalEmailMapping.get(itChangeRequestItem.ASI_eForm_Context__c);
                 uniqueExternalUserEmails.addAll(externalUserEmails);
                 
                 for (Id userId : userIds)
                 {
                     if (!userExceptionIDs.contains(userId)) 
                     {  
                         uniqueUserEmails.add(selectedUsersMap.get(userId).Email);
                     }
                 }
            }
            List<String> addresses = new List<String>();
            //List<String> externalAddresses = new List<String>();
            addresses.addAll(uniqueUserEmails);
            addresses.addAll(uniqueExternalUserEmails);
            //externalAddresses.addAll(uniqueExternalUserEmails); 
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(itChangeRequest.ownerId);
            
            if (itServiceDesk != null)
            {
            	email.setSenderDisplayName(itServiceDesk.DisplayName);
            	email.setReplyTo(itServiceDesk.Address);
            }
            
            email.setToAddresses(addresses);
            email.setWhatId(itChangeRequest.Id);
            email.setTemplateId(emailTemplate.Id);
            //email.setCCAddresses(externalAddresses);    
            allMail.add(email);
            System.debug('clk1230 ' + addresses)       ;               
        }    
        Messaging.SendEmailResult [] r = Messaging.sendEmail(allMail);  
   }
   
   public static void processITChangeRequestItemHeaders(Map<Id,ASI_eForm_IT_Change_Request__c> itcrMap)
   {
        AggregateResult[] invalidRequestGroupResults = [SELECT ASI_eForm_IT_Change_Request__c, Count(Id) 
          from ASI_eForm_IT_Change_Request_Item__c
        WHERE ASI_eForm_IT_Action__c = 'Invalid Submission'
        AND ASI_eForm_IT_Change_Request__c IN :itcrMap.keySet()
        group by ASI_eForm_IT_Change_Request__c];        
        
        /*
        RecordType itChangeRequestDraftRecordType = [Select Id from RecordType Where
        SobjectType='ASI_eForm_IT_Change_Request__c'  and  DeveloperName = 'ASI_HK_eForm_IT_Change_Request'];
        */
        
        Map<Id,RecordType> recordTypes = new Map<Id,RecordType>([SELECT Id, Name, DeveloperName from RecordType WHERE
        sObjectType = 'ASI_eForm_IT_Change_Request__c']);
        
        Map<String,RecordType> finalDraftRecordTypeMapping = new Map<String,RecordType>();
       
        for (RecordType recordType : recordTypes.values())    
        {
            if (!recordType.DeveloperName.contains('Final'))
            {
             finalDraftRecordTypeMapping.put(recordType.DeveloperName+'_Final',recordType);
            }
        }       
                
        Set<Id> invalidITCRequestGroupSet = new Set<Id>();
        
        for(AggregateResult invalidRequest : invalidRequestGroupResults )  
        {
            Id invalidUserId = (Id) invalidRequest.get('ASI_eForm_IT_Change_Request__c');
            invalidITCRequestGroupSet.add(invalidUserId);                                  
        }
        
        AggregateResult[] notCompleteRequestGroupResults = [SELECT ASI_eForm_IT_Change_Request__c, Count(Id) 
        from ASI_eForm_IT_Change_Request_Item__c
        WHERE (ASI_eForm_IT_Action__c != 'Complete')
        AND ASI_eForm_IT_Change_Request__c IN :itcrMap.keySet() 
        group by ASI_eForm_IT_Change_Request__c ];
        
        Set<Id> notCompleteRequestGroupSet = new Set<Id>();
        
        for(AggregateResult notCompleteRequest : notCompleteRequestGroupResults)  
        {
            Id notCompletedUserId = (Id) notCompleteRequest.get('ASI_eForm_IT_Change_Request__c');
            notCompleteRequestGroupSet.add(notCompletedUserId );                     
        }
         
        for (ASI_eForm_IT_Change_Request__c  itcrRequest : itcrMap.values()) 
        {
         if (invalidITCRequestGroupSet.contains(itcrRequest.Id))
         {
                 itcrRequest.ASI_eForm_IT_Action__c = 'Invalid Submission';
                 itcrRequest.ASI_eForm_Status__c = 'Draft';
                 itcrRequest.RecordTypeId = finalDraftRecordTypeMapping.get(itcrRequest.RecordType.DeveloperName).Id;
                 system.debug('clkItChangeRequest ' + itcrRequest.RecordTypeId);
         } else if(!notCompleteRequestGroupSet.contains(itcrRequest.Id)) 
         {
            itcrRequest.ASI_eForm_IT_Action__c = 'Complete';                      
            
         } else 
         {
             itcrRequest.ASI_eForm_IT_Action__c = 'Work In Progress';                               
         }
        }
        
        update  itcrMap.values(); 
   }
   
}