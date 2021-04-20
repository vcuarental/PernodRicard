/**
 * One trigger handler over account for the lat
 *
 * @author 
 */
trigger LAT_AccountOneTrigger on Account (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		// The handlerr does a RecordType first filter, either way, a recheck is being done in each encapsulated method


		LAT_AccountOneTriggerHandler handler = new LAT_AccountOneTriggerHandler(trigger.new, 
										trigger.oldMap,
										trigger.isInsert,
										trigger.isUpdate,
										trigger.isDelete,
										trigger.isBefore,
										trigger.isAfter
										);
		
		List<Account> brAccounts = handler.getAccountsForRts(AP01_Account_BR.BR_RECORDTYPES);
		List<Account> mxAccounts = handler.getAccountsForRts(LAT_MX_AP01_Account.MX_RECORDTYPES);
		system.debug('brAccoutns++++' + brAccounts);
		// if there are not lat accounts on the trigger stop the oneTrigger
		if (!handler.hasLatAccounts()){
			system.debug('Ernesto+++= NoLATACCS');
			return;
		}
		

		if (Trigger.isBefore) {
	    	
	    	system.debug('BR-Accounts:++' + brAccounts);
	    	//AP01_Account_BR.updatesInformationUnfilled(handler);
	    	//call your handler.before method
	    	if (Trigger.isInsert){
	    		if (brAccounts != null && !brAccounts.isEmpty()){
		            AP01_Account_BR.updatesInformationUnfilled(handler);
		            LAT_BR_AP01_AccountWOS.setRegionalAndMicroRegional(handler);
		    	}	

	    	} else if (Trigger.isUpdate){
	    		// MIGRATED TRIGGERS
	    		
		    	if (brAccounts != null && !brAccounts.isEmpty()){
		    		AP01_Account_BR.updateStatusIfReprovado(brAccounts, handler.getOldMap(), handler.latAccountByAccountId,handler.segmentationsByAccId,handler.segmentationsResultByAccId);
		            //AP01_Account_BR.updatesInformationUnfilled(handler);
		            AP01_Account_BR.Conta_valida_Inscricao_Estadual(brAccounts, handler.getOldMap());
		            AP01_Account_BR.updatesInformationUnfilled(handler);
		            AP01_Account_BR.setRatingActiveClient(brAccounts, handler.getOldMap());
		            LAT_BR_AP01_AccountWOS.updateRegionalAndMicroRegional(handler);
		    	}	

	    	} else if (Trigger.isDelete) {
	    		if (mxAccounts != null && !mxAccounts.isEmpty()){
	    			LAT_MX_AP01_Account.validatesAN8BeforeDeletion(trigger.old);
	    		}
	    	}
 

		} else if (Trigger.isAfter) {
	    	
	    	//call handler.after method
	    	if (Trigger.isInsert){

	    	} else if (Trigger.isUpdate){
	    		if (brAccounts != null && !brAccounts.isEmpty()) {
		    		AP01_Account_BR.ContaAutomatizaEnvioAprovacao(brAccounts, handler.getOldMap());
			        AP01_Account_BR.ContaCriaDemanda(brAccounts, handler.getOldMap());

			        system.debug('trigger account after update');
			        AP01_Account_BR.OwnerChangedFlagCheck(handler);
			        
			    }
	    	}
		}
}