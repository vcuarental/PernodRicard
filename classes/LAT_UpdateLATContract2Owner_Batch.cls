global class LAT_UpdateLATContract2Owner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
	
	String query;
	Map <Id, Id> accountNewOwner = new Map<Id, Id>();
	Set <Id> accounts = new Set <Id>();

	global LAT_UpdateLATContract2Owner_Batch(String headerId) {

		List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];

		for(LAT_MasiveOwnerLine__c line :lines){
			accounts.add(line.LAT_Account__c);
			accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
		}

		query = 'Select Id, ownerId, Account__c From LAT_Contract2__c where Account__c in :accounts';

	}
	
	global LAT_UpdateLATContract2Owner_Batch(Map<Id, Lat_Account__c> mapLatAccount) {

		accounts = mapLatAccount.keySet();
		accountNewOwner = new Map<Id, Id>();

		for(Lat_Account__c latacc :mapLatAccount.values()){
			
			accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
		}

		query = 'Select Id, ownerId, Account__c From LAT_Contract2__c where Account__c in :accounts';

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List <LAT_Contract2__c> lat_contracts2 = (List<LAT_Contract2__c>)scope;
		
		for (LAT_Contract2__c lat_contract : lat_contracts2) {
			
			lat_contract.ownerId = accountNewOwner.get(lat_contract.Account__c);
			
		}

		update lat_contracts2;
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}