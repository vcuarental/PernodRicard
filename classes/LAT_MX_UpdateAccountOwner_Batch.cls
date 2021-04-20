global class LAT_MX_UpdateAccountOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
	
	String query;
	Id newOwner;
	Id region;
	Id plaza;
	Set<Id> accountIds = new Set<Id>();
	List <Account> accountsToIntegrate;

	global LAT_MX_UpdateAccountOwner_Batch (Set<Id> accountIds, Id newOwnerId, Id plazaId, Id regionId) {
		
		this.newOwner = newOwnerId;
		this.plaza = plazaId;
		this.region = regionId;
		this.accountIds = accountIds;

		system.debug('>>>>>' + accountIds);
        system.debug('>>>>>' + newOwner);
        system.debug('>>>>> plazaId' + plaza);
        system.debug('>>>>> regionId' + region);

		query = 'Select id, LAT_Accountid__c, LAT_Accountid__r.OwnerId, LAT_Accountid__r.Owner.Name, LAT_MX_Region__c, LAT_MX_Plaza__c, ';
		query += ' LAT_MX_Descripcion__c, LAT_Region_Formula__c, LAT_Plaza_Formula__c From LAT_Account__c Where LAT_Accountid__c in :accountIds';
		system.debug('>>>>> query' + query);

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
   		List <LAT_Account__c> accounts = (List<LAT_Account__c>)scope;
		List<Account> actualAccs = new List<Account>();
		Set <Id> accountsToSearch = new Set<Id>();

		for (LAT_Account__c myAccount : accounts) {
			
			Date today = Date.today();
			String strConvertedDate = today.format();

			myAccount.LAT_MX_Descripcion__c = 'Ejecutivo previo: ' + myAccount.LAT_Accountid__r.Owner.Name + ' ultima Plaza : ' + myAccount.LAT_Plaza_Formula__c + ' - ultima Region: ' + myAccount.LAT_Region_Formula__c + ' - Última modificacion: ' + strConvertedDate;

			myAccount.LAT_Accountid__r.ownerId = newOwner;
			myAccount.LAT_MX_Region__c = region;
			myAccount.LAT_MX_Plaza__c = plaza;
			
			actualAccs.add(myAccount.LAT_Accountid__r);

			accountsToSearch.add(myAccount.LAT_Accountid__c);

		}

		//update myAccount.LAT_Accountid__r;
		update actualAccs;
		update accounts;

		accountsToIntegrate = [Select Id, Status__c, ParentId from Account where Id in: accountsToSearch];

	}
	
	global void finish(Database.BatchableContext BC) {

		LAT_MX_OnTrade_Account.notifyOnTradeChangeSync(accountsToIntegrate);
		
	}
	
}