//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_LATOpportunityBefore {
	
	public static void execute(){
		
		system.debug('antes recordtype');
	    //Filtrado de RecordTypes
	    LAT_Trigger trigger_MX = new LAT_Trigger('LAT_Opportunity__c', new set<String>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
	    
	    system.debug('despues recordtype');

	    //Ejecucion de metodos especificos para MX
	    if(trigger_MX.getNew()!= null && !trigger_MX.getNew().IsEmpty()){
	        LAT_MX_AP01_Opportunity.parentCustomerUpdate((List<LAT_Opportunity__c>)trigger_MX.getNew());
	        if(trigger.isInsert){
	            LAT_MX_AP01_Opportunity.initialStageUpdate((List<LAT_Opportunity__c>)trigger_MX.getNew());
	            LAT_MX_AP01_Opportunity.ChangeOwnerIfCoordinatorCRM((List<LAT_Opportunity__c>)trigger_MX.getNew());
	        }
	        if(trigger.isUpdate){
	            LAT_MX_AP01_Opportunity.salesOrderHandlerInterfaceAfterAP((List<LAT_Opportunity__c>)trigger_MX.getNew(),new Map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_MX.getOld()));
	            LAT_MX_AP01_Opportunity.updatesKAMPromisedDate(new Map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_MX.getNew()),new Map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_MX.getOld()));

	            system.debug('before update: ');
	            LAT_MX_AP01_Opportunity.evaluateIfNeedsCalculation(new Map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_MX.getNew()));
	        }
	    }else if(trigger_MX.getNew() == null && !trigger_MX.getOld().IsEmpty()){
	        if(trigger.isDelete){
	            LAT_MX_AP01_Opportunity.ValidationOnDelete((List<LAT_Opportunity__c>)trigger_MX.getOld());
	        }
	    }
	    
	}

}