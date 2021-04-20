//LAT_OpportunityLineItem__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

public with sharing class LAT_AR_LATOpportunityLineItemAfterUpdate {
	
	public static void execute(){
		
	    //Filtro por el RecordType de la oportunidad
	    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c',new set<String>{'OPP_1_NewOrder_ARG', 'OPP_2_NewOrder_URU', 'OPP_3_HeaderBlocked_ARG', 'OPP_4_HeaderBlocked_URU', 'OPP_5_OrderBlocked_ARG', 'OPP_6_OrderBlocked_URU'});
	    
	    List<LAT_OpportunityLineItem__c> triggerNew_AR = new List<LAT_OpportunityLineItem__c>();
	    List<LAT_OpportunityLineItem__c> triggerOld_AR = new List<LAT_OpportunityLineItem__c>();
	    
	    if(trigger.isDelete){
	        for(LAT_OpportunityLineItem__c oli :LAT_OpportunityLineItemTriggerHandler.triggerOld){
	            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
	                triggerOld_AR.add(oli);
	            }
	        }
	    }
	    if(trigger.isUpdate || trigger.isInsert){
	        for(LAT_OpportunityLineItem__c oli :LAT_OpportunityLineItemTriggerHandler.triggerNew){
	            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
	                triggerNew_AR.add(oli);
	            }
	        }
	    }
	    
	    //Llamadas a los metodos
	    if(!triggerNew_AR.isEmpty()){
	        if(trigger.isAfter && trigger.isUpdate){
	            LAT_AR_AP01_OpportunityLineItem.validateStatus(triggerNew_AR, LAT_OpportunityLineItemTriggerHandler.mapOld);
	            LAT_AR_AP01_OpportunityLineItem.existeItemEmBackOrder(triggerNew_AR);
	        }
	    } 
	    if( (!triggerNew_AR.isEmpty()) || (!triggerOld_AR.isEmpty()) ){
	        LAT_AR_AP01_OpportunityLineItem.updateStatusOpportunity(triggerNew_AR, triggerOld_AR, LAT_OpportunityLineItemTriggerHandler.mapOld);
	    }
	}


}