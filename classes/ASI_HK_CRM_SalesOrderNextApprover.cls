/*********************************************************************************
 * Name:ASI_HK_CRM_SalesOrderNextApprover
 * Description: 
 * Test Class: ASI_HK_CRM_SalesOrderNextApproverTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/11/2017       Wilken Lee          	[WL 1.0] Modify updateApprover method not to use @future to avoid batch apex limit
 * 30/11/2017       Wilken Lee          	[WL 2.0] "Approved" status need to be included in the Batch Apex call in order to clear the Next SO Approver field when approval complete
*********************************************************************************/
public without sharing class ASI_HK_CRM_SalesOrderNextApprover extends ASI_HK_CRM_TriggerAbstract{
  
  public set<Id> soIdSet;
  public static List<ProcessInstance> piList; 
  public List<ASI_HK_CRM_Sales_Order__c> soUpdateApproverList;
  public static ProcessInstanceWorkItem piwi;
  
    public ASI_HK_CRM_SalesOrderNextApprover() {
        super('ASI_HK_CRM_SalesOrderNextApprover');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) 
    {                
        if ((tAction == TriggerAction.AFTER_UPDATE) && !isBypassByCurrentUser()) 
        {  
          Map<ID, ASI_HK_CRM_Sales_Order__c> oldSOMap = (Map<ID, ASI_HK_CRM_Sales_Order__c>)oldMap;
          soIdSet = new set<Id>();
			
			/*[WL 1.0] BEGIN*/
			/*[WL 2.0] BEGIN*/
			//Set<String> nonApprovalOrderStatus = new Set<String>{'Draft', 'Approved', 'S', 'CS', 'IP'};
			Set<String> nonApprovalOrderStatus = new Set<String>{'Draft', 'S', 'CS', 'IP'};
			/*[WL 2.0] END*/
			/*[WL 1.0] END*/
			
          List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;          
		for (ASI_HK_CRM_Sales_Order__c so : soList){ 
			ASI_HK_CRM_Sales_Order__c oldSO = tAction == TriggerAction.AFTER_UPDATE ? (ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id) : null;
			System.debug('sona7 '+ oldSO.ASI_HK_CRM_Order_Status_Name__c);
			System.debug('sona8 '+ so.ASI_HK_CRM_Order_Status_Name__c);
			//if(oldSO.ASI_HK_CRM_Order_Status_Name__c != so.ASI_HK_CRM_Order_Status_Name__c){
			
			/*[WL 1.0] BEGIN*/
			if (!nonApprovalOrderStatus.contains(so.ASI_HK_CRM_Order_Status_Name__c))
				soIdSet.add(so.Id);
			/*[WL 1.0] END*/
			//}  
		}
      
      System.debug('sona3 '+ soIdSet.size());
      if(soIdSet.size() > 0 && !System.isfuture()){
        try{
          updateApprover(soIdSet);
        }
        catch(exception e){
          //System.debug('sona9' + !System.isfuture());
          //throw e;
          //throw new ASI_HK_CRM_CustomException('Error happen on update next approver');
        }
      }
      /*                
      piList = [SELECT Id, status, (SELECT Id, OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM workItems) 
         FROM ProcessInstance where targetObjectId in: soIdSet and status = 'Pending'];       
         
         System.debug('sona2 '+piList.size());
         if(piList.size() > 0 ){
           for(ProcessInstance pi : piList){
             piwi = pi.workItems;
             //approverMap.put(pi.targetObjectId, pi.workItem.OriginalActorId);
             approverMap.put(pi.targetObjectId, piwi.OriginalActorId);
             //System.debug('sona1 ' + piList.workItems.OriginalActor.Name);
           }
         }
         
      for (ASI_HK_CRM_Sales_Order__c so : soList){ 
        ASI_HK_CRM_Sales_Order__c oldSO = tAction == TriggerAction.AFTER_UPDATE ? (ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id) : null;
        if(oldSO.ASI_HK_CRM_Order_Status_Name__c != so.ASI_HK_CRM_Order_Status_Name__c){
          so.ASI_HK_CRM_Next_SO_Approver__c = approverMap.get(so.Id);
        }          
      }         
         */            
        }
      
    }
    
    @TestVisible
	@future	
	public static void updateApprover(Set<Id> soIdSet){
		List<ASI_HK_CRM_Sales_Order__c> soUpdateList = new List<ASI_HK_CRM_Sales_Order__c>();
		Map<Id, Id> approverMap = new Map<Id, Id>();
		
		soUpdateList = [select id, Name, ASI_HK_CRM_Next_SO_Approver__c from ASI_HK_CRM_Sales_Order__c where id in: soIdSet];
		
		piList = [SELECT Id, status, targetObjectId, (SELECT Id, OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM workItems) 
		   FROM ProcessInstance where targetObjectId in: soIdSet and status = 'Pending'];       
		   
		   System.debug('sona2 '+piList.size());
		   if(piList.size() > 0 ){
			 for(ProcessInstance pi : piList){
			   piwi = pi.workItems;
			   System.debug('sona5 '+pi.targetObjectId);
			   System.debug('sona4 '+piwi.OriginalActorId);
			   //approverMap.put(pi.targetObjectId, pi.workItem.OriginalActorId);
			   approverMap.put(pi.targetObjectId, piwi.OriginalActorId);
			   //System.debug('sona1 ' + piList.workItems.OriginalActor.Name);
			 }
		   }  
		   
		   /*for(ASI_HK_CRM_Sales_Order__c so : soUpdateList){
			 if(approverMap.get(so.id) != null){
			   so.ASI_HK_CRM_Next_SO_Approver__c = approverMap.get(so.id);
			 }
			 else{
			   so.ASI_HK_CRM_Next_SO_Approver__c = null;
			 }
		   }
			 
		   update soUpdateList;*/
		   // This will be called multiple times, must check if there is a need to update the sales order
		List<ASI_HK_CRM_Sales_Order__c> soToBeUpdated = new List<ASI_HK_CRM_Sales_Order__c>();
		for(ASI_HK_CRM_Sales_Order__c so : soUpdateList)
		{
			 if (approverMap.get(so.id) != so.ASI_HK_CRM_Next_SO_Approver__c)
		  {
			   if(approverMap.get(so.id) != null){
				 so.ASI_HK_CRM_Next_SO_Approver__c = approverMap.get(so.id);

				 soToBeUpdated.add(so);
			   }
			   else{
				 so.ASI_HK_CRM_Next_SO_Approver__c = null;
				 soToBeUpdated.add(so);
			   }
		  }
		}
		
		if (soToBeUpdated.size() > 0) 
		  update soToBeUpdated;
	}
  
  //Alternative/extra implementation: called by the ASI_HK_CRM_SalesOrderExtraItemRequest called after the approval is processed (SPECIAL CASE)
  public static void updateApprover2(Set<Id> soIdSet)
  {
    List<ASI_HK_CRM_Sales_Order__c> soUpdateList = new List<ASI_HK_CRM_Sales_Order__c>();
    Map<Id, Id> approverMap = new Map<Id, Id>();
    
    soUpdateList = [select id, Name, ASI_HK_CRM_Next_SO_Approver__c, ASI_HK_CRM_Order_Status_Name__c from ASI_HK_CRM_Sales_Order__c where id in: soIdSet];
    
	/*[WL 1.0 BEGIN]*/
    /*for (ASI_HK_CRM_Sales_Order__c so : soUpdateList)
      System.debug('soclk1 ' + so.ASI_HK_CRM_Order_Status_Name__c);*/
    /*[WL 1.0 END]*/
	
    piList = [SELECT Id, status, targetObjectId, (SELECT Id, OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM workItems) 
       FROM ProcessInstance where targetObjectId in: soIdSet and status = 'Pending'];       
       
       System.debug('altsona2 '+piList.size());
       if(piList.size() > 0 ){
         for(ProcessInstance pi : piList){
           piwi = pi.workItems;
           System.debug('altsona5 '+pi.targetObjectId);
           System.debug('altsona4 '+piwi.OriginalActorId);
           //approverMap.put(pi.targetObjectId, pi.workItem.OriginalActorId);
           approverMap.put(pi.targetObjectId, piwi.OriginalActorId);
           //System.debug('sona1 ' + piList.workItems.OriginalActor.Name);
         }
       }  
       
       // This will be called multiple times, must check if there is a need to update the sales order
    List<ASI_HK_CRM_Sales_Order__c> soToBeUpdated = new List<ASI_HK_CRM_Sales_Order__c>();
    for(ASI_HK_CRM_Sales_Order__c so : soUpdateList) 
    {
         if (approverMap.get(so.id) != so.ASI_HK_CRM_Next_SO_Approver__c)
      {
           if(approverMap.get(so.id) != null){
             so.ASI_HK_CRM_Next_SO_Approver__c = approverMap.get(so.id);
             soToBeUpdated.add(so);
           }
           else{
             so.ASI_HK_CRM_Next_SO_Approver__c = null;
             soToBeUpdated.add(so);
           }
      }
    }
    
    if (soToBeUpdated.size() > 0)
      update soToBeUpdated;
         
  }
       
    
}