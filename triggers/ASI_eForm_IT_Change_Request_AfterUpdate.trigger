trigger ASI_eForm_IT_Change_Request_AfterUpdate on ASI_eForm_IT_Change_Request__c (after update) {
    

    Map<Id,Set<Id>> itChangeRequestUserIdExemptMap = new Map<Id,Set<Id>>();
    Map<Id,ASI_eForm_IT_Change_Request__c> itChangeRequestMap =
     new Map<Id,ASI_eForm_IT_Change_Request__c>(); 
    
    Map<Id,RecordType> hkRecordTypeMap = new Map<Id,RecordType>([SELECT Id from RecordType Where 
     DeveloperName like '%ASI_eForm_HK_IT_Change_Request%' and sObjectType='ASI_eForm_IT_Change_Request__c']);
    
    for (ASI_eForm_IT_Change_Request__c itChangeRequest : Trigger.new)
    {
        if (itChangeRequest.ASI_eForm_Status__c=='Final' && 
              (hkRecordTypeMap.containsKey(itChangeRequest.RecordTypeId)) &&
            /*(itChangeRequest.ASI_eForm_IT_Action__c==null||itChangeRequest.ASI_eForm_IT_Action__c=='') &&*/
            (itChangeRequest.ASI_eForm_Status__c != trigger.oldMap.get(itChangeRequest.id).ASI_eForm_Status__c ))
        {

            Set<Id> userExceptionIDs = new Set<Id>();
            itChangeRequestUserIdExemptMap.put(itChangeRequest.Id,userExceptionIDs );
            
            if (itChangeRequest.ASI_eForm_Change_Authorizer__c != null)
            {
                userExceptionIDs.add(itChangeRequest.ASI_eForm_Change_Authorizer__c);
            }
            if (itChangeRequest.ASI_eForm_Further_Authorizer__c != null)
            {
                userExceptionIDs.add(itChangeRequest.ASI_eForm_Further_Authorizer__c );
            }
            if (itChangeRequest.ASI_eForm_High_Level_Authorizer__c != null)
            {
                userExceptionIDs.add(itChangeRequest.ASI_eForm_High_Level_Authorizer__c );
            }
            if (itChangeRequest.ASI_eForm_Preview_Approver__c != null)
            {
                userExceptionIDs.add(itChangeRequest.ASI_eForm_Preview_Approver__c );
            }
            if (itChangeRequest.ASI_eForm_Project_Coordinator__c != null)
            {
                userExceptionIDs.add(itChangeRequest.ASI_eForm_Project_Coordinator__c );
            }
            if (itChangeRequest.ASI_eForm_Project_Implementer__c != null)
            {
                userExceptionIDs.add(itChangeRequest.ASI_eForm_Project_Implementer__c );
            }
            itChangeRequestMap.put(itChangeRequest.Id,itChangeRequest);
        }
    }
    
    if (itChangeRequestUserIdExemptMap.size() > 0)
    {
      ASI_eForm_ITChangeRequestHandler.processITChangeRequest(itChangeRequestUserIdExemptMap,itChangeRequestMap);
    }

     map<String, String> mappedApproverAccessLevel = new Map<String, String>();
     mappedApproverAccessLevel.put('ASI_eForm_Preview_Approver__c', 'read');
     mappedApproverAccessLevel.put('ASI_eForm_Further_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_High_Level_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_Change_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_Project_Implementer__c','edit');
     mappedApproverAccessLevel.put('ASI_eForm_CN_Change_Authorizer__c','read');
     mappedApproverAccessLevel.put('ASI_eForm_CIO_Approver__c','read');

     ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_IT_Change_Request__Share', 
                                                            'ASI_eForm_IT_Change_Manager_Access__c', 
                                                            new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Further_Authorizer__c',
                                                                            'ASI_eForm_High_Level_Authorizer__c', 'ASI_eForm_Change_Authorizer__c', 
                                                                            'ASI_eForm_Project_Implementer__c', 'ASI_eForm_CN_Change_Authorizer__c',
                                                                            'ASI_eForm_CIO_Approver__c'}, 
                                                            trigger.oldMap, mappedApproverAccessLevel);  
        
}