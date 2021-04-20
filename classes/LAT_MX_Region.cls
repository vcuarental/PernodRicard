public with sharing class LAT_MX_Region {
	
	public LAT_MX_Region() {
		
	}

	public static void getAssociatedAccountsAndNotify(Set <Id> regionesNew){

		List <LAT_Account__c> lat_accounts = [Select id, LAT_Accountid__c, LAT_Accountid__r.ParentId From LAT_Account__c where LAT_MX_Region__c in :regionesNew];
		
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

	public static void getOwnerAccountsAndSetNewRegion(Map<Id, LAT_MX_Region__c> regiones){

		Set <Id> newRegionOwners = new Set <Id>();
		Map <Id, LAT_MX_Region__c> mapOwnerRegion = new Map <Id, LAT_MX_Region__c>();

		for (LAT_MX_Region__c region :regiones.values()){

			newRegionOwners.add(region.LAT_MX_KAM__c);
			
			mapOwnerRegion.put(region.LAT_MX_KAM__c, region);
			system.debug('region.LAT_MX_KAM__c: ' + region.LAT_MX_KAM__c + ' region: ' + region);
		}

		List <LAT_Account__c> lat_accounts = [Select id, LAT_Accountid__c, LAT_Accountid__r.owner.managerid, LAT_Accountid__r.ownerId, LAT_MX_Region__c From LAT_Account__c where LAT_Accountid__r.owner.managerid in :newRegionOwners and LAT_Accountid__r.recordtype.developername = 'LAT_MX_ACC_OnTrade'];
		
		if(!lat_accounts.isEmpty()){
			for(LAT_Account__c latacc :lat_accounts){
				if(mapOwnerRegion.containsKey(latacc.LAT_Accountid__r.owner.managerid)){
				   
				   latacc.LAT_MX_Region__c = mapOwnerRegion.get(latacc.LAT_Accountid__r.owner.managerid).Id;
 
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
	}

}