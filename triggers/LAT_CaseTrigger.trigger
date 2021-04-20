trigger LAT_CaseTrigger on LAT_Case__c (before insert,before update, before delete,after insert, after update, after delete ) {

    if(trigger.isAfter && trigger.isUpdate){
        LAT_CaseTriggerHandler.init(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
         
        LAT_BR_AP01_Case.UpdateStatusCaseClose(trigger.New);
        AP02_CaseWOS_AR.UpdateStatusCaseClose(trigger.New);
        
        LAT_LATCase_CancelaContrato.execute();
        LAT_LATCase_ReservaIBP.execute();
        LAT_BR_LATCase_Tratamento.execute();
        LAT_BR_LATCase_BeforeInsertUpdate.execute();
        LAT_BR_AP01_Case.shareWithAccountOwner(Trigger.newMap, Trigger.oldMap);

    }else if(trigger.isAfter && trigger.isInsert){
        LAT_CaseTriggerHandler.init(Trigger.new, null, Trigger.newMap, null); 
        LAT_Case_AfterInsert.execute();
        LAT_BR_AP01_Case.UpdateStatusCaseClose(trigger.New);
        AP02_CaseWOS_AR.UpdateStatusCaseClose(trigger.New);
        LAT_AR_Case_Update_Owner.UpdateCaseOwner(trigger.New);
        LAT_AR_Case_Update_Owner.shareRecordsWithAccountOwner(trigger.New);
		AP01_Case_AR.processNewB2BCase(trigger.New);
	
        LAT_BR_LATCase_BeforeInsertUpdate.execute();
        LAT_LATCase_CancelaContrato.execute();
        
    }else if(trigger.isBefore && trigger.isUpdate){
        LAT_CaseTriggerHandler.init(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
        
        LAT_BR_LATCase_BeforeInsertUpdate.execute();
        LAT_AR_LATCase_BeforeInsertUpdate.execute();
        LAT_LATCase_AtualizaCamposContrato.execute();
        LAT_BR_LATCase_CopiaAgrupamentoFiscal.execute();
        LAT_LATCase_CopiaIdGerenteRegionalArea.execute();
        LAT_BR_LATCase_CopiaTipoDeVerbaAgFiscal.execute();
        
    }else if(trigger.isBefore && trigger.isInsert){
        LAT_CaseTriggerHandler.init(Trigger.new, null, null, null); 
        LAT_AR_LATCase_BeforeInsertUpdate.execute();
        LAT_LATCase_AtualizaCamposContrato.execute();
        LAT_BR_LATCase_CopiaAgrupamentoFiscal.execute();
        LAT_LATCase_CopiaIdGerenteRegionalArea.execute();
        LAT_BR_LATCase_CopiaTipoDeVerbaAgFiscal.execute();
        LAT_MX_LATCase_Before.execute();
        LAT_BR_AP01_Case.checkCaseForOwnerChange();
    }
    
    
}