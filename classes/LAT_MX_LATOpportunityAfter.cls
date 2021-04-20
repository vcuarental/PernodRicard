//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_LATOpportunityAfter  {
	
	public static void execute(){
		
	    //Filtrado de RecordTypes
	    LAT_Trigger trigger_MX = new LAT_Trigger('LAT_Opportunity__c', new set<String>{'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'});
	            
	    //Ejecucion de metodos especificos para MX
		
	    if(!trigger_MX.getOld().IsEmpty()){
	        LAT_MX_AP02_OpportunityWOS.updatesAvailableCreditLimit(new Map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_MX.getOld()));
	   		if (trigger_MX.getNew() != null) {
	   			if (!trigger_MX.getNew().IsEmpty()) {
	   				LAT_MX_AP02_OpportunityWOS.postToChatter(trigger_MX.getNew(), new Map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_MX.getOld()));
	   			}
	   		}
	    }
	    
	    
	}

	public static void executeOnInsert(){
		System.debug('%%%% entro en LAT_MX_LATOpportunityAfter');
		for (LAT_Opportunity__c opp : LAT_OpportunityTriggerHandler.triggerNew) {
			if  (LAT_MX_WS03_SalesOrderHandlerInterface.isProcessing == null) {
	    		LAT_MX_WS03_SalesOrderHandlerInterface.isProcessing = false;
	    	}
	        if (!LAT_MX_WS03_SalesOrderHandlerInterface.isProcessing &&
	             opp.LAT_StageName__c == 'Mobile Order' && (opp.LAT_Country__c == 12)) {

	        	if (LAT_OpportunityTriggerHandler.triggerNew.size() == 1){
	        		LAT_MX_BTN07_OpportunityValidations.metodo(opp.Id);	
	        	}
	         	// Only works for one opp at the time
	         	// TODO: bulkify method
	         	
		        
	        	// size = 1
	        	//LAT_MX_BTN07_OpportunityValidations.PaymentPeridoValidation().equals('OK')
	        	//  ESTA ERA LA FUNCIONALIDAD PREVIA, SE CAMBIO A metodopivoto que elige
	        	//System.debug('%%%% entro en el el if de LAT_MX_LATOpportunityAfter');
	            //LAT_MX_WS03_SalesOrderHandlerInterface.SalesOrderInterfaceFuture(opp.Id);
	            //LAT_MX_WS03_SalesOrderHandlerInterface.isProcessing = true;
	        }

		}

	}
}