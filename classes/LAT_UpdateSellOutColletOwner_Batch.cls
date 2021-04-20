global class LAT_UpdateSellOutColletOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
	
	String query;
	Map <Id, Id> accountNewOwner = new Map<Id, Id>();
	Set <Id> accounts = new Set <Id>();

	global LAT_UpdateSellOutColletOwner_Batch(String headerId) {

		List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];

		for(LAT_MasiveOwnerLine__c line :lines){
			accounts.add(line.LAT_Account__c);
			accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
		}

		query = 'Select Id, ownerId, AccountID__c From LAT_SellOutCollect__c where AccountID__c in :accounts';

	}

	global LAT_UpdateSellOutColletOwner_Batch(Map<Id, Lat_Account__c> mapLatAccount) {

		accounts = mapLatAccount.keySet();
		accountNewOwner = new Map<Id, Id>();

		for(Lat_Account__c latacc :mapLatAccount.values()){
			
			accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
		}

		query = 'Select Id, ownerId, AccountID__c From LAT_SellOutCollect__c where AccountID__c in :accounts';

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List <LAT_SellOutCollect__c> lat_collects = (List<LAT_SellOutCollect__c>)scope;
		
		for (LAT_SellOutCollect__c lat_collect : lat_collects) {
			
			lat_collect.ownerId = accountNewOwner.get(lat_collect.AccountID__c);
			
		}

		update lat_collects;
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}