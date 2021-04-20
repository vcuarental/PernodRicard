//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_AR_LATOpportunityAfter  {
	
	public static void execute(){

		List<LAT_Opportunity__Share> toUpdate = shareRecordsWithAccountOwner(LAT_OpportunityTriggerHandler.triggerNew);
        
        if (!toUpdate.isEmpty()){

	    	try{
				Database.insert(toUpdate,false);
			}catch(exception ex){
				LAT_DebugUtil debugUtil = new LAT_DebugUtil();
	            debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
	            debugUtil.setOrigin('LAT OPPORTUNITY');
	            debugUtil.insertDebug();
			}
	    }

		for (LAT_Opportunity__c opp : LAT_OpportunityTriggerHandler.triggerNew) {

	    	if  (WS03_SalesOrderHandlerInterface_AR.isProcessing == null) {
	    		WS03_SalesOrderHandlerInterface_AR.isProcessing = false;
	    	}
	        if (!WS03_SalesOrderHandlerInterface_AR.isProcessing &&
	             opp.LAT_StageName__c == 'Mobile Order' && (opp.LAT_Country__c == 5 || opp.LAT_Country__c == 6)) {
	            WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(opp.Id);
	            WS03_SalesOrderHandlerInterface_AR.isProcessing = true;
	        }
	    }

	}

	public static List<LAT_Opportunity__Share> shareRecordsWithAccountOwner(List<LAT_Opportunity__c> triggerNew){
		
		List<LAT_Opportunity__Share> toUpdate = new List<LAT_Opportunity__Share>(); 
		List<id> tmpIds = new List<id>();
		
		for (LAT_Opportunity__c opp : triggerNew){
             tmpIds.add(opp.id);
        }

		List<LAT_Opportunity__c> opps = [Select id, LAT_Account__c, LAT_Account__r.OwnerId, LAT_LeadSource__c From LAT_Opportunity__c Where id in :tmpIds];

		for(LAT_Opportunity__c opp :opps){
            if(opp.LAT_LeadSource__c != 'B2B'){
                LAT_Opportunity__Share jobShr  = new LAT_Opportunity__Share();
                jobShr.ParentId = opp.Id;
                jobShr.UserOrGroupId = opp.LAT_Account__r.OwnerId;
                jobShr.AccessLevel = 'Read';
                jobShr.RowCause = 'Manual';
    
                toUpdate.add(jobShr);
            }
			
		}

		return toUpdate;
	}

}