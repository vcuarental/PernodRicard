trigger LAT_OpportunityTrigger on LAT_Opportunity__c (before insert, before update, before delete, after insert, after update, after delete) {

	if(trigger.isAfter && trigger.isUpdate){ 
        LAT_OpportunityTriggerHandler.init(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
         
        LAT_LATOpportunity_CodigoAcaoCancelado.execute();
        LAT_AR_LATOpportunityAfterUpdate.execute();
        LAT_BR_LATOpportunityAfter.execute();
        LAT_MX_LATOpportunityAfter.execute();
    }else if(trigger.isAfter && trigger.isInsert){
        LAT_OpportunityTriggerHandler.init(Trigger.new, null, Trigger.newMap, null); 
        
        LAT_AR_LATOpportunityAfter.execute();    
        LAT_BR_LATOpportunityAfter.execute();
        LAT_MX_LATOpportunityAfter.executeOnInsert();
    
    }else if(trigger.isBefore && trigger.isUpdate){
        LAT_OpportunityTriggerHandler.init(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
        
        LAT_LATOpportunity_AtualizaDataEntrega.execute();
        LAT_BR_LATOpportunityBefore.execute();
        LAT_LATOpportunity_CodigoAcaoCancelado.execute();
        LAT_MX_LATOpportunityBefore.execute();
        
    }else if(trigger.isBefore && trigger.isInsert){
        LAT_OpportunityTriggerHandler.init(Trigger.new, null, null, null); 
       
       	//LAT_LATOpportunity_AtualizaDataEntrega.execute();
       	LAT_BR_LATOpportunityBefore.execute();
       	LAT_AR_LATOpportunityBeforeInsert.execute();
       	LAT_MX_LATOpportunityBefore.execute();

    }else if(trigger.isBefore && trigger.isDelete){
        LAT_OpportunityTriggerHandler.init(null, Trigger.old, null, Trigger.oldMap); 
        LAT_BR_LATOpportunityBefore.validateIfOppIsIntegrated();
        LAT_BR_LATOpportunityBefore.execute();
        LAT_MX_LATOpportunityBefore.execute();
    }else if(trigger.isAfter && trigger.isDelete){
    	LAT_OpportunityTriggerHandler.init(null, Trigger.old, null, Trigger.oldMap); 

    	LAT_MX_LATOpportunityAfter.execute();
    }
}