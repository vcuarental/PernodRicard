trigger ASI_eForm_IT_Procurement_Service_Request_BeforeUpdate on ASI_eForm_IT_Procurement_Service_Request__c (before update) {

    List<Id> itpsrIds = new List<Id>();
    List<Id> recordTypeIds = new List<Id>();
    List<String> companies = new List<String>();
    List<String> departments = new List<String>();
    List<String> formTypes = new List<String>();
    
    Map<ID, User> userOwnerMap = ASI_eForm_GenericTriggerClass.mapUser(trigger.new); 
    
    for (ASI_eForm_IT_Procurement_Service_Request__c itpsr : Trigger.new)
    {
    	if (itpsr.ownerid != trigger.oldMap.get(itpsr.id).ownerid)
    		itpsr = (ASI_eForm_IT_Procurement_Service_Request__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(itpsr, userOwnerMap));  
        
        if (itpsr.ASI_eForm_Status__c == 'Draft')
        {
            itpsrIds.add(itpsr.id);
            recordTypeIds.add(itpsr.recordtypeId);
        }
    }
   
   if (itpsrIds.size() > 0)
   {
   Map<Id,RecordType> recordTypeMap = new  Map<Id,RecordType>([SELECT Id,Name from RecordType
   where Id in :recordTypeIds]);
    
   AggregateResult[] financeDirectorsGroupResults = [SELECT ASI_eForm_IT_Procurement_Service_Request__c, Count(Id) 
   from ASI_eForm_IT_Procurement_Service_Item__c 
   where ASI_eForm_FD_Approve_Required__c = true
   AND (ASI_eForm_IT_Procurement_Service_Request__c in :itpsrIds) 
   group by ASI_eForm_IT_Procurement_Service_Request__c];
   
   Map<Id,Id> itpsrIdFinanceDirectorMap = new Map<Id,Id>(); 
   for (AggregateResult financeDirectorsGroupResult:financeDirectorsGroupResults)
   {
       itpsrIdFinanceDirectorMap.put((Id)financeDirectorsGroupResult.get('ASI_eForm_IT_Procurement_Service_Request__c'),
       (Id)financeDirectorsGroupResult.get('ASI_eForm_IT_Procurement_Service_Request__c'));
   }
   
   AggregateResult[] cioGroupResults = [SELECT ASI_eForm_IT_Procurement_Service_Request__c, Count(Id) 
   from ASI_eForm_IT_Procurement_Service_Item__c 
   where ASI_eForm_CIO_Approve_Required__c = true
   AND (ASI_eForm_IT_Procurement_Service_Request__c in :itpsrIds) 
   group by ASI_eForm_IT_Procurement_Service_Request__c];
   
   Map<Id,Id> cioMap = new Map<Id,Id>(); 
   for (AggregateResult cioGroupResult:cioGroupResults)
   {
       cioMap.put((Id)cioGroupResult.get('ASI_eForm_IT_Procurement_Service_Request__c'),
       (Id)cioGroupResult.get('ASI_eForm_IT_Procurement_Service_Request__c'));
   }
   
   Map<Id,Id> itpsrOwnerIdMap = new Map<Id,Id>();
   
   for (ASI_eForm_IT_Procurement_Service_Request__c itpsr : Trigger.new)
   {
        itpsrOwnerIdMap.put(itpsr.Id,itpsr.OwnerId);     
        formTypes.add(itpsr.RecordType.Name); 
   }
     
      Map<Id,User> usersMap = new Map<Id,User>([Select ID, Department, CompanyName from User 
      where Id in :itpsrOwnerIdMap.values()]); 
      
      for (User user : usersMap.values())
      {
          departments.add(user.Department);
          companies.add(user.CompanyName);      
      }
      
      List<ASI_eForm_Route_Rule_Details__c> routeTypes = 
      [SELECT ASI_eForm_Route_Type__r.ASI_eForm_Company__c,
              ASI_eForm_Route_Type__r.ASI_eForm_Department__c,
              ASI_eForm_Route_Type__r.ASI_eForm_Form_Record_Type__c,
              ASI_eForm_Route_Type__r.ASI_eForm_Form_Type__c,
              ASI_eForm_Note__c,
              ASI_eForm_Approver__c  
        FROM ASI_eForm_Route_Rule_Details__c where 
      ASI_eForm_Route_Type__c in
       (select id 
            from ASI_eForm_Route_Type__c
            WHERE ASI_eForm_Company__c in :companies OR
            ASI_eForm_Department__c in :departments OR
            ASI_eForm_Form_Type__c in :formTypes)];
          
      //System.debug('XXX Route Types: ' + routeTypes );    
            
      Map<String,ASI_eForm_Route_Rule_Details__c> routingMap = new Map<String,ASI_eForm_Route_Rule_Details__c>();
      
      for(ASI_eForm_Route_Rule_Details__c routeRuleDetail : routeTypes )
      {
          String routeKey = routeRuleDetail.ASI_eForm_Route_Type__r.ASI_eForm_Company__c
          + routeRuleDetail.ASI_eForm_Route_Type__r.ASI_eForm_Department__c
          + routeRuleDetail.ASI_eForm_Route_Type__r.ASI_eForm_Form_Type__c
          + routeRuleDetail.ASI_eForm_Route_Type__r.ASI_eForm_Form_Record_Type__c
          + routeRuleDetail.ASI_eForm_Note__c;     
          System.debug('XXX Route Key: ' + routeKey);             
          routingMap.put(routeKey,routeRuleDetail);     
      }
      
      //Update Finance Department
      for(ASI_eForm_IT_Procurement_Service_Request__c itpsiToBeUpdated: Trigger.new)
      {
          
          if (itpsiToBeUpdated.ASI_eForm_Status__c == 'Draft')
          {
          if (itpsrIdFinanceDirectorMap.get(itpsiToBeUpdated.Id) != null)
          {
              User currentUser = usersMap.get(itpsiToBeUpdated.OwnerId);
              String routeKey = currentUser.CompanyName 
              + currentUser.Department
              + ASI_eForm_PreFillApproversHandler.IT_PROC_SERVICE_REQUEST 
              + recordTypeMap.get(itpsiToBeUpdated.RecordTypeId).Name
              + ASI_eForm_PreFillApproversHandler.FINANCE_DIRECTOR;           
              System.debug('XXX Request Key: ' + routeKey);
              
              ASI_eForm_Route_Rule_Details__c  routeDetail = routingMap.get(routeKey); 
              if (routeDetail != null && itpsiToBeUpdated.ASI_eForm_Finance_Director__c == null)
              {
               itpsiToBeUpdated.ASI_eForm_Finance_Director__c = routeDetail.ASI_eForm_Approver__c;
              }
          } else if (itpsiToBeUpdated.ASI_eForm_Finance_Director__c != null)
          {
              itpsiToBeUpdated.ASI_eForm_Finance_Director__c = null;
          }
          
          if (cioMap.get(itpsiToBeUpdated.Id) != null)
          {
              User currentUser = usersMap.get(itpsiToBeUpdated.OwnerId);
              String routeKey = currentUser.CompanyName 
              + currentUser.Department
              + ASI_eForm_PreFillApproversHandler.IT_PROC_SERVICE_REQUEST 
              + recordTypeMap.get(itpsiToBeUpdated.RecordTypeId).Name
              + ASI_eForm_PreFillApproversHandler.CIO;           
              System.debug('XXX Request Key: ' + routeKey);
              
              ASI_eForm_Route_Rule_Details__c  routeDetail = routingMap.get(routeKey); 
              if (routeDetail != null && itpsiToBeUpdated.ASI_eForm_CIO__c == null)
              {
               itpsiToBeUpdated.ASI_eForm_CIO__c = routeDetail.ASI_eForm_Approver__c;
              }
          } else if (itpsiToBeUpdated.ASI_eForm_CIO__c != null)
          {
              itpsiToBeUpdated.ASI_eForm_CIO__c = null;
          }
        }
      }   
    }    
}