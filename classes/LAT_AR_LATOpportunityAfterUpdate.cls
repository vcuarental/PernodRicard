//LAT_Opportunity__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_AR_LATOpportunityAfterUpdate {
	
	public static void execute(){
		for (LAT_Opportunity__c opp : LAT_OpportunityTriggerHandler.triggerNew) {
			/*if(WS03_SalesOrderHandlerInterface_AR.processingIds == null) {
	    		WS03_SalesOrderHandlerInterface_AR.processingIds = new Set<Id>();
	    	}
	        if (!WS03_SalesOrderHandlerInterface_AR.processingIds.contains(opp.Id) &&
	            opp.LAT_CDAction__c == 'C'
	            && opp.LAT_CDAction__c  != LAT_OpportunityTriggerHandler.mapOld.get(opp.Id).LAT_CDAction__c
	            && opp.LAT_CancelOrder__c) {
	        	cancelOpportunity(opp.id);
	        } else if(!WS03_SalesOrderHandlerInterface_AR.processingIds.contains(opp.Id) &&
	            (opp.LAT_StageName__c == 'Pedido con descuento aprobado' || opp.LAT_StageName__c == 'Approved' || opp.LAT_StageName__c == 'Mobile Order' || opp.LAT_StageName__c == 'Pedido Ofrecido aprobado')
	            && opp.LAT_StageName__c != LAT_OpportunityTriggerHandler.mapOld.get(opp.Id).LAT_StageName__c) {
	           
	            WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(opp.Id);
	            WS03_SalesOrderHandlerInterface_AR.processingIds.add(opp.Id);
	        }
			*/

	    	if  (WS03_SalesOrderHandlerInterface_AR.isProcessing == null) {
	    		WS03_SalesOrderHandlerInterface_AR.isProcessing = false;
	    	}
	        if (!WS03_SalesOrderHandlerInterface_AR.isProcessing &&
	            opp.LAT_CDAction__c == 'C'
	            && opp.LAT_CDAction__c  != LAT_OpportunityTriggerHandler.mapOld.get(opp.Id).LAT_CDAction__c
	            && opp.LAT_CancelOrder__c) {
	        	cancelOpportunity(opp.id);
	        }else if (!WS03_SalesOrderHandlerInterface_AR.isProcessing &&
	            (opp.LAT_StageName__c == 'Pedido con descuento aprobado' || opp.LAT_StageName__c == 'Approved' || opp.LAT_StageName__c == 'Mobile Order' || opp.LAT_StageName__c == 'Pedido Ofrecido aprobado')
	            && opp.LAT_StageName__c != LAT_OpportunityTriggerHandler.mapOld.get(opp.Id).LAT_StageName__c) {
	            WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(opp.Id);
	            WS03_SalesOrderHandlerInterface_AR.isProcessing = true;
	        }
			checkCancelledB2BOpportunity(opp);
	    }


	    
	}

	public static void checkCancelledB2BOpportunity(LAT_Opportunity__c opp){
		if(opp.LAT_StageName__c == 'Pedido cancelado no JDE' && LAT_OpportunityTriggerHandler.mapOld.get(opp.Id).LAT_StageName__c != 'Pedido cancelado no JDE'
			&& opp.LAT_LeadSource__c == 'B2B'){
			LAT_CTY_B2B_OrderController.sendOpportunityCancelledEmail(opp.Id);
		}
	}

	public static void cancelOpportunity(String oppId){
		List<LAT_OpportunityLineItem__c> oportunidadeLista = [ SELECT id, LAT_CDAction__c, LAT_Remover__c, LAT_CdLineStatus__c
                                                               FROM LAT_OpportunityLineItem__c 
                                                               WHERE LAT_Opportunity__c = :oppId];

        
     
        
        for(LAT_OpportunityLineItem__c item : oportunidadeLista){
            try {
                integer intStatus = Integer.valueOf(item.LAT_CdLineStatus__c);
                if (intStatus <= 540) {
                    item.LAT_CDAction__c = 'C';
                    item.LAT_Remover__c = true;
                }
            } catch (Exception ex) {
                system.debug('%%%%%%%% Error al cancelar linea: ' + ex.getMessage());
            }
        }
        update oportunidadeLista;

        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(oppId);
	    WS03_SalesOrderHandlerInterface_AR.isProcessing = true;
	}

}