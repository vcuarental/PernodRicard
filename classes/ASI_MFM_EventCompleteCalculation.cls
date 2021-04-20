/* Filename:	ASI_MFM_EventCompleteCalculation.cls
 * Author:	Michael Yip (Introv Limited)
 * Purpose:	Re-calculate completed event outlet on event basis for CN MFM
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-03-29	michael.yip@introv.com		Created
 * 
 */
global class ASI_MFM_EventCompleteCalculation implements Database.Batchable<sObject>{ 
    
	global database.querylocator start(Database.BatchableContext BC){
	 // This methods returns a SOQL query locator containing the records
	 String CNEventRecID = Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_MFM_CN_Event');
	 String CNEventOutletRecID = Global_RecordTypeCache.getRtId('ASI_MFM_Event_Outlet__cASI_MFM_CN_Event_Outlet');
            return Database.getQueryLocator([Select id, name, ASI_MFM_CN_Completed_Outlet__c, 
            	(select id, name, ASI_MFM_Completed__c from ASI_MFM_Event__c.Event_Outlets__r) 
            	from ASI_MFM_Event__c where recordtypeid = :CNEventRecID]);
            
     }
     global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<ASI_MFM_Event__c> LEvent = new List<ASI_MFM_Event__c>();
		for(ASI_MFM_Event__c event : (List<ASI_MFM_Event__c>) scope) {
		  event.ASI_MFM_CN_Completed_Outlet__c = 0;
		  System.debug(event);
		  System.debug(event.Event_Outlets__r);	
		  for(ASI_MFM_Event_Outlet__c outlet : event.Event_Outlets__r) { 
		    // processing
		    if(outlet.ASI_MFM_Completed__c){
		    	event.ASI_MFM_CN_Completed_Outlet__c++;
		    }
		  }
		  LEvent.add(event);
		}
		if(LEvent.size()>0){
			update Levent;
		}
     }
     
     global void finish(Database.BatchableContext BC){
	   // Get the ID of the AsyncApexJob representing this batch job  
    
   // from Database.BatchableContext.  
    
   // Query the AsyncApexJob object to retrieve the current job's information.  
    
   AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      from AsyncApexJob where Id =
      :BC.getJobId()];
   // Send an email to the Apex job's submitter notifying of job completion.  
    
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 //  String[] toAddresses = new String[] {a.CreatedBy.Email};
   String[] toAddresses = new String[] {'prasia.mobile@pernod-ricard.com'};   
   mail.setToAddresses(toAddresses);
   mail.setSubject('Event Complete Calculation : Apex Sharing Recalculation ' + a.Status);
   mail.setPlainTextBody
   ('The batch Apex job processed ' + a.TotalJobItems +
   ' batches with '+ a.NumberOfErrors + ' failures.');
   //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	
	}
     
}