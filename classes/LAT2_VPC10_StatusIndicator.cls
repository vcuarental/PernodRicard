/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/

public with sharing class LAT2_VPC10_StatusIndicator {

	public String state{get;set;}


	public LAT2_VPC10_StatusIndicator(ApexPages.standardController controller) {
		LAT_Opportunity__c opp = [Select id,LAT_StageName__c, (Select id,LAT_MX_RealDeliveryDate__c from OpportunityLineItems__r)  from LAT_Opportunity__c where id =: controller.getRecord().Id];

		state = opp.LAT_StageName__c;

		if (opp.LAT_StageName__c == 'Pedido enviado para o JDE'){
			state = 'Novo pedido';
		} else if (opp.LAT_StageName__c == 'Pedido con descuento en aprobación' || opp.LAT_StageName__c == 'Pedido em Aprovação' || opp.LAT_StageName__c == 'Pedido con descuento aprobado' || opp.LAT_StageName__c == 'Approval pending' || opp.LAT_StageName__c == 'Approved' || opp.LAT_StageName__c == 'Pedido Ofrecido aprobado' || opp.LAT_StageName__c == 'Pedido Ofrecido en aprobación'){
			state = 'En Aprobación';
		} else if (opp.LAT_StageName__c == 'Pedido retenido en Cuota' || opp.LAT_StageName__c == 'Pedido ingresado en JDE' || opp.LAT_StageName__c == 'Pedido retenido en Créditos' 
		 			|| opp.LAT_StageName__c == 'Pedido en Logística' || opp.LAT_StageName__c == 'Pedido parcialmente atendido' || opp.LAT_StageName__c == 'Pedido totalmente atendido') {
			state = 'Pedido processado no JDE';
		}


		Integer contDelivered = 0;

		for(LAT_OpportunityLineItem__c oli: opp.OpportunityLineItems__r){
			if (oli.LAT_MX_RealDeliveryDate__c != null) {
                contDelivered++;
            } 
		}
		if (contDelivered > 0) {
	        if (contDelivered == opp.OpportunityLineItems__r.size()) {
	            state = 'Totalmente Entregado';
	        } else {
	            state = 'Parcialmente Entregado';
	        }
	    }
	}
}