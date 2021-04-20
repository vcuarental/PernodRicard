trigger LAT_BR_OpportunityAfter on Opportunity (after update,after insert) {
	//Filtro por el RecordType de la oportunidad
    LAT_Trigger trigger_BR = new LAT_Trigger('Opportunity', new set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao'});
    
    //Llamadas a los metodos 
    if(trigger.isUpdate){
        LAT_BR_TR_Opportunity.validateAndIntegrate((List<Opportunity>)trigger_BR.getNew());
        LAT_BR_TR_Opportunity.cancelOpportunity((List<Opportunity>)trigger_BR.getNew(), new map<Id,Opportunity>((List<Opportunity>)trigger_BR.getOld()));
    	if(!trigger_BR.getOld().isEmpty()){
    		LAT_BR_TR_Opportunity.createFeedOnStatusUpdate((List<Opportunity>)trigger_BR.getNew(), (List<Opportunity>)trigger_BR.getOld());
    	}
    }

	if(trigger.isInsert){
		LAT_BR_VFC12_CreditoDisponivelController.updateRequestDate((List<Opportunity>)trigger_BR.getNew());
        LAT_BR_TR_Opportunity.validateAndIntegrate((List<Opportunity>)trigger_BR.getNew());
		for(Opportunity tmpOpp: (List<Opportunity>)trigger_BR.getNew()){ 
            LAT_BR_VFC12_CreditoDisponivelController.setInitCreditoDisponible(tmpOpp.accountId);
        }
	}

    if (trigger.isInsert) {
        system.debug('Opty---->' + trigger.new);
    }
}