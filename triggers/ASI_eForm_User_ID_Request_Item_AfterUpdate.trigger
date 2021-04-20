trigger ASI_eForm_User_ID_Request_Item_AfterUpdate  on ASI_eForm_User_ID_Request_Item__c (after update) {

    Set<Id> uirIds = new Set<Id>(); 
    
    for (ASI_eForm_User_ID_Request_Item__c uidr : Trigger.new)
    {
       uirIds.add(uidr.ASI_eForm_User_ID_Request__c);
    }
    
    Map<Id,ASI_eForm_User_ID_Request__c> uirMap = new Map<Id,ASI_eForm_User_ID_Request__c>(
    [Select Id, RecordTypeId, ASI_eForm_User_Profile_Name__c, ASI_eForm_User_Alias__c , ASI_eForm_Status__c, RecordType.DeveloperName, ASI_eForm_IT_Action__c  
     from ASI_eForm_User_ID_Request__c
     where ASI_eForm_Status__c = 'Final' and Id in :uirIds]
    );    
   
    if (uirMap.size() > 0)
    {
        //Issue #5 20140905 Enable Items IT Action's to be changed from Complete to WIP or IT Acknowledged
        if(uirMap.values().get(0).ASI_eForm_IT_Action__c == 'Complete')
        {
            ASI_eForm_GenericTriggerClass.reverseCompleteITAction(uirMap, trigger.new, trigger.oldmap, 'ASI_eForm_User_ID_Request__c;ASI_eForm_IT_Action__c', 'ASI_eForm_IT_Action__c;ASI_eForm_Status__c');
        }
        else
        {
        //End of fix
        
        AggregateResult[] invalidRequestGroupResults = [SELECT ASI_eForm_User_ID_Request__c, Count(Id) 
        from ASI_eForm_User_ID_Request_Item__c 
        WHERE ASI_eForm_IT_Action__c = 'Invalid Submission'
        AND ASI_eForm_User_ID_Request__c IN :uirMap.keySet()
        group by ASI_eForm_User_ID_Request__c];  
        
        Set<Id> invalidRequestGroupSet = new Set<Id>();
        
        for(AggregateResult invalidRequest : invalidRequestGroupResults)  
        {
            Id invalidUserId = (Id) invalidRequest.get('ASI_eForm_User_ID_Request__c');
            if (!invalidRequestGroupSet.contains(invalidUserId ))
            {
              invalidRequestGroupSet.add(invalidUserId);              
            }        
        }
        
        
        Map<Id,RecordType> recordTypes = new Map<Id,RecordType>([SELECT Id, Name, DeveloperName from RecordType WHERE
        sObjectType = 'ASI_eForm_User_ID_Request__c']);
        
        Map<String,RecordType> finalDraftRecordTypeMapping = new Map<String,RecordType>();
       
        for (RecordType recordType : recordTypes.values())    
        {
            if (!recordType.DeveloperName.contains('Final'))
            {
             finalDraftRecordTypeMapping.put(recordType.DeveloperName+'_Final',recordType);
            }
        }        
        
                        
        AggregateResult[] notCompleteRequestGroupResults = [SELECT ASI_eForm_User_ID_Request__c, 
        Count(Id) from ASI_eForm_User_ID_Request_Item__c 
        WHERE (ASI_eForm_IT_Action__c != 'Complete')
        AND ASI_eForm_User_ID_Request__c IN :uirMap.keySet()
        group by ASI_eForm_User_ID_Request__c];
        
        Set<Id> notCompleteRequestGroupSet = new Set<Id>();
        
        for(AggregateResult notCompleteRequest : notCompleteRequestGroupResults)  
        {
            Id notCompletedUserId = (Id) notCompleteRequest.get('ASI_eForm_User_ID_Request__c');
            if (!notCompleteRequestGroupSet.contains(notCompletedUserId ))
            {
              notCompleteRequestGroupSet.add(notCompletedUserId );              
            }        
        }
                
        for (ASI_eForm_User_ID_Request__c  userIDRequest: uirMap.values()) 
        {
         if (invalidRequestGroupSet.contains(userIDRequest.Id))
         {
                 
                 userIDRequest.ASI_eForm_IT_Action__c = 'Invalid Submission';
                 userIDRequest.ASI_eForm_Status__c = 'Draft';
                 RecordType newRecordType = finalDraftRecordTypeMapping.get(userIDRequest.RecordType.DeveloperName);
                 userIDRequest.RecordTypeId = newRecordType.Id;
                 system.debug('clkUserIdRequest ' + userIDRequest.RecordTypeId);
                     
         } else if(!notCompleteRequestGroupSet.contains(userIDRequest.Id)) 
         {
             RecordType recordType = recordTypes.get(userIDRequest.RecordTypeId);
             //Issue #7 20140905 Change recordtype detection from label to developername
             if (!recordType.developername.contains('ASI_eForm_HK_New_Employee') && (userIDRequest.ASI_eForm_User_Profile_Name__c == null)
             )
             {
                for (ASI_eForm_User_ID_Request_Item__c  userIDRequestItem : Trigger.new)
                {
                  if (userIDRequestItem.ASI_eForm_User_ID_Request__c ==  userIDRequest.Id)
                  {
                   userIDRequestItem.addError('User Profile Cannot Be Empty');
                  } 
                } //Issue #7 20140905 Change recordtype detection from label to developername
             } else if (recordType.developerName.contains('ASI_eForm_HK_New_Employee') && (userIDRequest.ASI_eForm_User_Alias__c== null)
             )
             {
                for (ASI_eForm_User_ID_Request_Item__c  userIDRequestItem : Trigger.new)
                {
                  if (userIDRequestItem.ASI_eForm_User_ID_Request__c ==  userIDRequest.Id)
                  {
                   userIDRequestItem.addError('User Alias Cannot Be Empty');
                  } 
                } 
             }
             {
                 userIDRequest.ASI_eForm_IT_Action__c = 'Complete';
                 userIDRequest.ASI_eForm_Sys_User_Permission_Applied__c = true;                      
             }
         } else
         {
             userIDRequest.ASI_eForm_IT_Action__c = 'Work In Progress';         
         }
       } 
       update uirMap.values();
       } 
    }

}