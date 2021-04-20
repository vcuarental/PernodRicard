/********************************************************************************************
*   Company:Valuenet             Developers:Waldemar Mayo           Date:12/12/2013    		*
********************************************************************************************/

trigger LAT_BR_OpportunityBefore on Opportunity (before delete, before insert, before update) {
    
    //Filtro por el RecordType de la oportunidad
    LAT_Trigger trigger_BR = new LAT_Trigger('Opportunity', new set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao'});
    
    //Llamadas a los metodos 
    if(trigger.isDelete){
    	if(!trigger_BR.getOld().isEmpty()){
    		LAT_BR_AP01_Opportunity.updateStockCota((List<Opportunity>)trigger_BR.getOld());
        	LAT_BR_AP01_Opportunity.validateStatusDelete((List<Opportunity>)trigger_BR.getOld());
    	}
	}
    if(trigger.isInsert || trigger.isUpdate){
    	if(!trigger_BR.getNew().isEmpty()){
    		if(trigger.isInsert){
    			LAT_BR_AP01_Opportunity.setMobileOrder((List<Opportunity>)trigger_BR.getNew());
    		}
			LAT_BR_AP01_Opportunity.checkAllowWebCRM((List<Opportunity>)trigger_BR.getNew());
		}
    }
}