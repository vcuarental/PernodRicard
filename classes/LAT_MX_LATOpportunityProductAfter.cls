//LAT_OpportunityLineItem__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_LATOpportunityProductAfter {
	
	public static void execute(){
		
	    //Filtrado de RecordTypes. Opportunity Product no tiene Record Type y por eso se necesito hacer un Query de las Oportunidades relacionadas
	    Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c',new set<String>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
	    
	    List<LAT_OpportunityLineItem__c> triggerNew_MX = new List<LAT_OpportunityLineItem__c>();
	    Map<Id,LAT_OpportunityLineItem__c> OldMap_MX = new Map<Id,LAT_OpportunityLineItem__c>();
	    
	    if(trigger.isInsert || trigger.isUpdate){
	        for(LAT_OpportunityLineItem__c oli: LAT_OpportunityLineItemTriggerHandler.triggerNew){
	            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
	                triggerNew_MX.add(oli);
	                if(trigger.isUpdate){
	                    OldMap_MX.put(oli.Id,LAT_OpportunityLineItemTriggerHandler.mapOld.get(oli.Id));
	                }
	            }
	        }
	    }else{
	        for(LAT_OpportunityLineItem__c oli: LAT_OpportunityLineItemTriggerHandler.triggerOld){
	            if(setOppRt.contains(oli.LAT_OpportunityRecordTypeId__c)){
	                OldMap_MX.put(oli.Id,LAT_OpportunityLineItemTriggerHandler.mapOld.get(oli.Id));
	            }
	        }        
	    }
	      
	    //Ejecucion de metodos especificos para MX
	    if(!triggerNew_MX.isEmpty() || !OldMap_MX.isEmpty()){
	        LAT_MX_AP01_OpportunityProducts.quotaCalculation(triggerNew_MX,OldMap_MX);
	        LAT_MX_AP01_OpportunityProducts.blockOrder(triggerNew_MX,OldMap_MX);
	    }
	    if((triggerNew_MX != null && !triggerNew_MX.isEmpty()) || (OldMap_MX != null && !OldMap_MX.isEmpty())){
	        LAT_MX_AP02_OpportunityProductsWOS.updatesAvailableCreditLimit(triggerNew_MX,OldMap_MX);
	    }

	    
	    
	}

}