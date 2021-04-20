//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_LATOpportunityAfter {
	
	public static void execute(){
		//Filtro por el RecordType de la oportunidad
	    LAT_Trigger trigger_BR = new LAT_Trigger('LAT_Opportunity__c', new set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao'});
	    
	    //Llamadas a los metodos 
	    if(trigger.isUpdate){
	        LAT_BR_TR_Opportunity.validateAndIntegrate((List<LAT_Opportunity__c>)trigger_BR.getNew());
	        LAT_BR_TR_Opportunity.cancelOpportunity((List<LAT_Opportunity__c>)trigger_BR.getNew(), new map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_BR.getOld()));
	    	if(!trigger_BR.getOld().isEmpty()){
	    		LAT_BR_TR_Opportunity.createFeedOnStatusUpdate((List<LAT_Opportunity__c>)trigger_BR.getNew(), (List<LAT_Opportunity__c>)trigger_BR.getOld());
	    		LAT_BR_TR_Opportunity.validateFlexApprovalRejected((List<LAT_Opportunity__c>)trigger_BR.getNew(), new map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_BR.getOld()));
				LAT_BR_TR_Opportunity.validateEDIApprovalApproved((List<LAT_Opportunity__c>)trigger_BR.getNew(), new map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_BR.getOld()));
				LAT_BR_TR_Opportunity.checkIsEDIReteined((List<LAT_Opportunity__c>)trigger_BR.getNew(), new map<Id,LAT_Opportunity__c>((List<LAT_Opportunity__c>)trigger_BR.getOld()));
	    	}
	    }

		if(trigger.isInsert){
			LAT_BR_VFC12_CreditoDisponivelController.updateRequestDate((List<LAT_Opportunity__c>)trigger_BR.getNew());
	        LAT_BR_TR_Opportunity.validateAndIntegrate((List<LAT_Opportunity__c>)trigger_BR.getNew());
			for(LAT_Opportunity__c tmpOpp: (List<LAT_Opportunity__c>)trigger_BR.getNew()){ 
	            LAT_BR_VFC12_CreditoDisponivelController.setInitCreditoDisponible(tmpOpp.LAT_account__c);
	        }
	        LAT_BR_TR_Opportunity.checkIsEDIReteined((List<LAT_Opportunity__c>)trigger_BR.getNew(), null);
		}

	    
	}

}