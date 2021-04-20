trigger LAT_Deposit on DPT_Deposit_ARG__c (before insert,before update,before delete, after insert, after update) {
	
	if (trigger.isAfter && trigger.isUpdate) { 
        
    } else if(trigger.isAfter && trigger.isInsert) {
        LAT_Deposit.createRelatedRUValues(Trigger.newMap);
    
    } else if(trigger.isBefore && trigger.isUpdate) {
        LAT_Deposit.DepositCheckPrintStatus(Trigger.newMap);
        LAT_Deposit.createDeposit(Trigger.new);
	    LAT_Deposit.updateBankSlipNo(Trigger.new);
        LAT_Deposit.checkRUDepositIsNotModified(Trigger.oldMap, Trigger.new);
        
    } else if(trigger.isBefore && trigger.isInsert) {
        LAT_Deposit.createDeposit(Trigger.new);
	    LAT_Deposit.updateBankSlipNo(Trigger.new);

    } else if(trigger.isBefore && trigger.isDelete) {
        LAT_Deposit.DepositCheckPrintStatus(Trigger.oldMap);

    } else if(trigger.isAfter && trigger.isDelete) {
    	
    }

}