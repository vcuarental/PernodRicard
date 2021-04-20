trigger ASI_eForm_IT_Procurement_Service_Item_AfterProcess on ASI_eForm_IT_Procurement_Service_Item__c (after insert, after update, after delete) {

  Map<Id,ASI_eForm_IT_Procurement_Service_Request__c> itpsiWithNewRequests = new Map<Id,ASI_eForm_IT_Procurement_Service_Request__c>();
  
     if (!Trigger.isDelete)
     {                
      for (ASI_eForm_IT_Procurement_Service_Item__c itProcSrvcItem : Trigger.new)
      {
          if (!itpsiWithNewRequests.containsKey(itProcSrvcItem.ASI_eForm_IT_Procurement_Service_Request__c))
           {
                itpsiWithNewRequests.put(itProcSrvcItem.ASI_eForm_IT_Procurement_Service_Request__c,
                new ASI_eForm_IT_Procurement_Service_Request__c(Id=itProcSrvcItem.ASI_eForm_IT_Procurement_Service_Request__c));
           }          
      }     

      /*if (Trigger.isAfter && Trigger.isInsert)
      {
         ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_IT_Procurement_Service_Request__Share', 
                                                            'ASI_eForm_IT_Procurement_Manager_Access__c', 
                                                            new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Approver__c', 'ASI_eForm_Finance_Director__c',
                                                                            'ASI_eForm_CIO__c'}, 
                                                            null);
      }*/

      if (Trigger.isAfter && Trigger.isUpdate)
      {
            Map<Id,ASI_eForm_IT_Procurement_Service_Request__c> itpsrMap = new Map<Id,ASI_eForm_IT_Procurement_Service_Request__c>(
    [Select Id, ASI_eForm_Status__c, ASI_eForm_IT_Action__c, RecordType.DeveloperName from ASI_eForm_IT_Procurement_Service_Request__c Where Id in :itpsiWithNewRequests.keySet() and
    ASI_eForm_Status__c = 'Final']);
    
    List<RecordType> draftRecordTypes = [Select Id, DeveloperName from RecordType where
        sObjectType = 'ASI_eForm_IT_Procurement_Service_Request__c' and (NOT DeveloperName like '%Final%' )]; 
       
    Map<String,RecordType> finalDraftRecordTypeMapping = new Map<String,RecordType>();
       
    for (RecordType draftRecordType : draftRecordTypes)    
    {
        finalDraftRecordTypeMapping.put(draftRecordType.DeveloperName+'_Final',draftRecordType);
    }
    
    System.debug('XXXX finalDraftRecordTypeMapping ' + finalDraftRecordTypeMapping );
    
    if (itpsrMap.size() > 0 )
    {
    
        //Issue #5 20140905 Enable Items IT Action's to be changed from Complete to WIP or IT Acknowledged
        if(itpsrMap.values().get(0).ASI_eForm_IT_Action__c == 'Complete')
        {
            ASI_eForm_GenericTriggerClass.reverseCompleteITAction(itpsrMap, trigger.new, trigger.oldmap, 'ASI_eForm_IT_Procurement_Service_Request__c;ASI_eForm_IT_Action__c', 'ASI_eForm_IT_Action__c;ASI_eForm_Status__c');
        }
        else
        {
        //End of fix
        
        AggregateResult[] invalidRequestGroupResults = [SELECT ASI_eForm_IT_Procurement_Service_Request__c, Count(Id) 
        from ASI_eForm_IT_Procurement_Service_Item__c
        WHERE ASI_eForm_IT_Action__c = 'Invalid Submission'
        AND ASI_eForm_IT_Procurement_Service_Request__c IN :itpsrMap.keySet()
        group by ASI_eForm_IT_Procurement_Service_Request__c];        
                
        Set<Id> invalidITPSRequestGroupSet = new Set<Id>();
        
        for(AggregateResult invalidRequest : invalidRequestGroupResults )  
        {
            Id invalidId = (Id) invalidRequest.get('ASI_eForm_IT_Procurement_Service_Request__c');
            invalidITPSRequestGroupSet.add(invalidId);                                  
        }
        
        AggregateResult[] notCompleteRequestGroupResults = [SELECT ASI_eForm_IT_Procurement_Service_Request__c, Count(Id) 
        from ASI_eForm_IT_Procurement_Service_Item__c
        WHERE (ASI_eForm_IT_Action__c != 'Complete')
        AND ASI_eForm_IT_Procurement_Service_Request__c IN :itpsrMap.keySet() 
        group by ASI_eForm_IT_Procurement_Service_Request__c];
        
        Set<Id> notCompleteRequestGroupSet = new Set<Id>();
        
        for(AggregateResult notCompleteRequest : notCompleteRequestGroupResults)  
        {
            Id notCompletedUserId = (Id) notCompleteRequest.get('ASI_eForm_IT_Procurement_Service_Request__c');
            notCompleteRequestGroupSet.add(notCompletedUserId );                     
        }
         
        for (ASI_eForm_IT_Procurement_Service_Request__c itpsRequest : itpsrMap.values()) 
        {
         if (invalidITPSRequestGroupSet.contains(itpsRequest.Id))
         {
                 itpsRequest.ASI_eForm_IT_Action__c = 'Invalid Submission';
                 itpsRequest.ASI_eForm_Status__c = 'Draft';
                 RecordType newRecordType = finalDraftRecordTypeMapping.get(itpsRequest.RecordType.DeveloperName);
                 itpsRequest.RecordTypeId = newRecordType.Id;
                 System.debug('clkItProcurement ' + newRecordType);
                 
         } else if(!notCompleteRequestGroupSet.contains(itpsRequest.Id)) 
         {
            itpsRequest.ASI_eForm_IT_Action__c = 'Complete';                      
            
         } else 
         {
             itpsRequest.ASI_eForm_IT_Action__c = 'Work In Progress';                               
         }
         itpsiWithNewRequests.put(itpsRequest.Id,itpsRequest);
        }       
    }
    }
     /*ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_IT_Procurement_Service_Request__Share', 
                                                            'ASI_eForm_IT_Procurement_Manager_Access__c', 
                                                            new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Approver__c', 'ASI_eForm_Finance_Director__c',
                                                                            'ASI_eForm_CIO__c'}, 
                                                            trigger.oldMap);*/
    
   }
      
    } else
    {
      for (ASI_eForm_IT_Procurement_Service_Item__c itProcSrvcItem : Trigger.old)
      {
          if (!itpsiWithNewRequests.containsKey(itProcSrvcItem.ASI_eForm_IT_Procurement_Service_Request__c))
           {
               itpsiWithNewRequests.put(itProcSrvcItem.ASI_eForm_IT_Procurement_Service_Request__c,
               new ASI_eForm_IT_Procurement_Service_Request__c(Id=itProcSrvcItem.ASI_eForm_IT_Procurement_Service_Request__c));
           }
      }
    
    }
    
   if (itpsiWithNewRequests.size() > 0)
   {
       update itpsiWithNewRequests.values();
   }    
}