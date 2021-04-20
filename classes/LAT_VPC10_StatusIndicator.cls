public with sharing class LAT_VPC10_StatusIndicator {

	public String state{get;set;}


	public LAT_VPC10_StatusIndicator(ApexPages.standardController controller) {
		Opportunity opp = [Select id,stagename, (Select id,LAT_MX_RealDeliveryDate__c from OpportunityLineItems)  from Opportunity where id =: controller.getRecord().Id];

		state = opp.stagename;

		if(opp.stagename == 'Pedido enviado para o JDE'){
			state = 'Novo pedido';
		}else if(opp.stagename == 'Pedido con descuento en aprobación' || opp.stagename == 'Pedido em Aprovação' || opp.stagename == 'Pedido con descuento aprobado' || opp.stagename == 'Approval pending' || opp.stagename == 'Approved'){
			state = 'En Aprobación';
		}

		Integer contDelivered = 0;

		for(OpportunityLineItem oli: opp.OpportunityLineItems){
			if (oli.LAT_MX_RealDeliveryDate__c != null) {
                contDelivered++;
            } 
		}
		if (contDelivered > 0) {
	        if (contDelivered == opp.OpportunityLineItems.size()) {
	            state = 'Totalmente Entregado';
	        } else {
	            state = 'Parcialmente Entregado';
	        }
	    }
	}
}