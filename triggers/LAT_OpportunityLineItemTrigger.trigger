trigger LAT_OpportunityLineItemTrigger on LAT_OpportunityLineItem__c (before insert, before update, before delete, after insert, after update, after delete) {
	
	if(trigger.isAfter && trigger.isUpdate){
		LAT_OpportunityLineItemTriggerHandler.init(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
		
		LAT_BR_LATOpportunityProductAfter.execute();
		LAT_MX_LATOpportunityProductAfter.execute();
		LAT_BR_OportunidadeAtualizaDataEntrega.execute();
		LAT_AR_LATOpportunityLineItemAfterUpdate.execute();

    }else if(trigger.isAfter && trigger.isInsert){    
        LAT_OpportunityLineItemTriggerHandler.init(Trigger.new, null, Trigger.newMap, null); 
        
        LAT_BR_LATOpportunityProductAfter.execute();
        LAT_MX_LATOpportunityProductAfter.execute();
        LAT_BR_OportunidadeAtualizaDataEntrega.execute();
        LAT_AR_LATOpportunityLineItemAfterUpdate.execute();

    }else if(trigger.isBefore && trigger.isUpdate){        
        LAT_OpportunityLineItemTriggerHandler.init(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
    	
        LAT_AR_LATOpportunityProductBefore.execute();
    	LAT_BR_LATOpportunityProductBefore.execute();
    	LAT_MX_LATOpportunityProductBefore.execute();
    	LAT_OportunidadeVerificaCotaExistente.execute();


    }else if(trigger.isBefore && trigger.isInsert){       
        LAT_OpportunityLineItemTriggerHandler.init(Trigger.new, null, null, null); 
    	
    	LAT_BR_LATOpportunityProductBefore.execute();
    	LAT_MX_LATOpportunityProductBefore.execute();
    	LAT_OportunidadeVerificaCotaExistente.execute();

    }else if(trigger.isBefore && trigger.isDelete){
        LAT_OpportunityLineItemTriggerHandler.init(null, Trigger.old, null, Trigger.oldMap); 
    	
    	LAT_OportunidadeVerificaCotaExistente.execute();

    }else if(trigger.isAfter && trigger.isDelete){
    	LAT_OpportunityLineItemTriggerHandler.init(null, Trigger.old, null, Trigger.oldMap); 
    
    	LAT_MX_LATOpportunityProductAfter.execute();
    	LAT_BR_OportunidadeAtualizaDataEntrega.execute();
    	LAT_AR_LATOpportunityLineItemAfterUpdate.execute();
    }
}