//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public with sharing class LAT_AR_LATCase_BeforeInsertUpdate {
	public static map<Id, RecordType> mapIdRt = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('LAT_Case__c'));

	public static void execute(){
	   
	    set<String> rtsARUY = new Set<String>{'B2B_Support','B2B_New_Account','CSE_1_AccountAlteration_ARG','CSE_2_AccountAlteration_URU','CSE_OverdueAccount_AR','CSE_OverdueAccount_UY','CSE_OverdueJustification_AR','CSE_OverdueJustification_UY','CSE_OverdueToAttorneys_AR','CSE_OverdueToAttorneys_UY','CSE_PaymentProposal_AR','CSE_PaymentProposal_UY','CSE_WOPaymentProposal_AR','CSE_WOPaymentProposal_UY'};
	        
	    List<LAT_Case__c> triggerNewARUY = new List<LAT_Case__c>();
	    map<Id, LAT_Case__c> triggerOldMapARUY = new map<Id, LAT_Case__c>();
	    for(LAT_Case__c cse: LAT_CaseTriggerHandler.triggerNew){
	        if(rtsARUY.contains(mapIdRt.get(cse.RecordTypeId).DeveloperName) ){
	            triggerNewARUY.add(cse);
	            if(trigger.isUpdate){
	                triggerOldMapARUY.put(cse.Id, LAT_CaseTriggerHandler.mapOld.get(cse.Id));
	            }
	        }        
	    }
	    if(!triggerNewARUY.isEmpty()){
	        if ( (trigger.isUpdate ) || (trigger.isInsert )){
	            AP01_Case_AR.UpdateAccountOwnerAndManagerOwner(triggerNewARUY);
	            AP01_Case_AR.UpdateRtandIsoCode(triggerNewARUY);
	            AP01_Case_AR.UpdateSubject(triggerNewARUY, 'insert');
	        }
	        if (trigger.isUpdate  ){
	            AP01_Case_AR.TypeValidation(triggerNewARUY, triggerOldMapARUY);
	            AP02_CaseWOS_AR.ApprovalProcessFlow(triggerNewARUY, triggerOldMapARUY);
	            AP01_Case_AR.ValidateCloseCase(triggerNewARUY);
	            AP01_Case_AR.validateB2BClosedCase(triggerNewARUY);
	        }
	    }
	}
}