public with sharing class LAT_MX_Plaza {
	
	public LAT_MX_Plaza() {
		
	}

	public static void validateUniquePlaza (List <LAT_MX_Plaza__c> plazasNew){

		Map <Id, LAT_MX_Plaza__c> plazasMap = new Map <Id, LAT_MX_Plaza__c>();
		List <LAT_MX_Plaza__c> plazas = [Select id, name, LAT_MX_Ejecutivo__c, LAT_MX_Ejecutivo__r.LAT_MX_Is_KAM__c From LAT_MX_Plaza__c];

		for (LAT_MX_Plaza__c plaza :plazas){

			plazasMap.put(plaza.LAT_MX_Ejecutivo__c, plaza);

		}

		for (LAT_MX_Plaza__c plaza :plazasNew){
			if (plazasMap.containsKey(plaza.LAT_MX_Ejecutivo__c) && plazasMap.get(plaza.LAT_MX_Ejecutivo__c).LAT_MX_Ejecutivo__r.LAT_MX_Is_KAM__c == false){

				plaza.addError(Label.LAT_MX_PLAZA_001);
			}
		}
		
	}

	public static void getAssociatedAccountsAndNotify(Set <Id> plazasNew){

		List <LAT_Account__c> lat_accounts = [Select id, LAT_Accountid__c, LAT_Accountid__r.ParentId From LAT_Account__c where LAT_MX_Plaza__c in :plazasNew];
		
		Set <Id> accountsToSearch = new Set<Id>();

		for (LAT_Account__c lataccount :lat_accounts){
			if (lataccount.LAT_Accountid__r.ParentId == null) {
				accountsToSearch.add(lataccount.LAT_Accountid__c);
			} else {
				accountsToSearch.add(lataccount.LAT_Accountid__r.ParentId);
			}
			

		}

		List <Account> accountsToIntegrate = [Select Id, Status__c, ParentId from Account where Id in: accountsToSearch];
		for (Account acc : accountsToIntegrate) {
			acc.Status__c = 'Modification requested in CRM';
		}

		LAT_MX_OnTrade_Account.notifyOnTradeChange(accountsToIntegrate);

	}

	public static void getOwnerAccountsAndSetNewPlaza(Map<Id, LAT_MX_Plaza__c> plazas){

		Set <Id> newOwners = new Set <Id>();
		Map <Id, LAT_MX_Plaza__c> mapOwnerPlaza = new Map <Id, LAT_MX_Plaza__c>();

		for (LAT_MX_Plaza__c plaza :plazas.values()){

			newOwners.add(plaza.LAT_MX_Ejecutivo__c);
			mapOwnerPlaza.put(plaza.LAT_MX_Ejecutivo__c, plaza);
		}

		List <LAT_Account__c> lat_accounts = [Select id, LAT_Accountid__c, LAT_Accountid__r.ownerId, LAT_MX_Plaza__c From LAT_Account__c where LAT_Accountid__r.ownerId in :newOwners and LAT_Accountid__r.recordtype.developername = 'LAT_MX_ACC_OnTrade'];
		
		if(!lat_accounts.isEmpty()){
			for(LAT_Account__c latacc :lat_accounts){
				if(mapOwnerPlaza.containsKey(latacc.LAT_Accountid__r.ownerId)){
				   
				   latacc.LAT_MX_Plaza__c = mapOwnerPlaza.get(latacc.LAT_Accountid__r.ownerId).Id;
 
				}
			}
		}
		
		update lat_accounts;

		Set <Id> accountsToUpdate = new Set<Id>();
		
		for(LAT_Account__c latAccount :lat_accounts){
			accountsToUpdate.add(latAccount.LAT_Accountid__c);
		}
				
		List <Account> accountsToIntegrate = [Select Id, Status__c, ParentId from Account where Id in: accountsToUpdate];

		for (Account acc : accountsToIntegrate) {
			acc.Status__c = 'Modification requested in CRM';
		}
		
		LAT_MX_OnTrade_Account.notifyOnTradeChange(accountsToIntegrate);

		//Database.executeBatch(new LAT_MX_UpdateAccountOwner_Batch(accounts, accNewLookup.ownerid, plazaId, regionId), 1);

	}

}