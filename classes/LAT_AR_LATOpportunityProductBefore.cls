public with sharing class LAT_AR_LATOpportunityProductBefore {
	
	public LAT_AR_LATOpportunityProductBefore() {
		
	}
	
	public static void execute(){
		//Filtrado de RecordTypes. Opportunity Product no tiene Record Type y por eso se necesito hacer un Query de las Oportunidades relacionadas
	    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c',new set<String>{'OPP_1_NewOrder_ARG', 'OPP_2_NewOrder_URU', 'OPP_3_HeaderBlocked_ARG', 'OPP_4_HeaderBlocked_URU', 'OPP_5_OrderBlocked_ARG', 'OPP_6_OrderBlocked_URU'});
	    
	    List<LAT_OpportunityLineItem__c> triggerNew_AR = new List<LAT_OpportunityLineItem__c>();
	    Map<Id,LAT_OpportunityLineItem__c> OldMap_AR = new Map<Id,LAT_OpportunityLineItem__c>();
	    
	    if(trigger.isUpdate){
	    	for(LAT_OpportunityLineItem__c oli : LAT_OpportunityLineItemTriggerHandler.triggerNew){
	    		if (setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)) {
	    			if(oli.LAT_CdLineStatus__c == '540') {
		            	if (oli.LAT_Description__c != null && oli.LAT_Description__c != '') {
		            		oli.LAT_StatusDescription__c = 'Retenido en Créditos';
			            } else {
			            	 oli.LAT_StatusDescription__c = 'En Logística';	
		            	}		                
		            }	
	    		}
	        }
	    }
    
	}
		
	
}