//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_LATOpportunityBefore  {
	
	public static void execute(){
		 
	    //Filtro por el RecordType de la oportunidad
	    LAT_Trigger trigger_BR = new LAT_Trigger('LAT_Opportunity__c', new set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao'});
	    
	    //Llamadas a los metodos 
	    if(trigger.isDelete){
	    	if(!trigger_BR.getOld().isEmpty()){
	    		LAT_BR_AP01_Opportunity.updateStockCota((List<LAT_Opportunity__c>)trigger_BR.getOld());
	        	LAT_BR_AP01_Opportunity.validateStatusDelete((List<LAT_Opportunity__c>)trigger_BR.getOld());
	    	}
		}
	    if(trigger.isInsert || trigger.isUpdate){
	    	if(!trigger_BR.getNew().isEmpty()){
	    		if(trigger.isInsert){
	    			LAT_BR_AP01_Opportunity.setMobileOrder((List<LAT_Opportunity__c>)trigger_BR.getNew());
	    		}
				LAT_BR_AP01_Opportunity.checkAllowWebCRM((List<LAT_Opportunity__c>)trigger_BR.getNew());
				LAT_BR_AP01_Opportunity.setFreihgtCRM((List<LAT_Opportunity__c>)trigger_BR.getNew());
			}
	    }
	}

	public static void validateIfOppIsIntegrated() {
		//Filtro por el RecordType de la oportunidad (para este chequeo uso todos los RT, ya que aplica a todos los paises)
	    LAT_Trigger trigger_LAT = new LAT_Trigger('LAT_Opportunity__c', new set<String>{'Nova_oportunidade', 'Bloqueia_alteracao_do_cabecalho', 'Bloqueia_alteracao'
	    																				,'LAT_MX_OPP_HeaderBlocked','LAT_MX_OPP_NewOrder','LAT_MX_OPP_OrderBlocked'
	    																				,'OPP_1_NewOrder_ARG','OPP_2_NewOrder_URU', 'OPP_3_HeaderBlocked_ARG', 'OPP_4_HeaderBlocked_URU'
	    																				, 'OPP_5_OrderBlocked_ARG', 'OPP_6_OrderBlocked_URU' });

	    if (trigger.isDelete) {
	    	if(!trigger_LAT.getOld().isEmpty()){
	    		for (LAT_Opportunity__c opp : (List<LAT_Opportunity__c>)trigger_LAT.getOld()) {
	    			if (opp.LAT_StageName__c == 'Moblie Order Sent To JDE' || opp.LAT_StageName__c == 'Pedido enviado para o JDE' 
	    				|| (opp.LAT_JDEOrderKey__c != null && opp.LAT_JDEOrderKey__c != '')) {
	    				if(!opp.LAT_IsAdmin__c) {
	    					opp.addError(Label.LAT_TR_ErrorIntegratedOpp);
	    					//No es posible eliminar un Pedido que ya fue enviado a JDE.
	    				}
	    			}
	    		}
	    	}
	    }
	    
	}

}