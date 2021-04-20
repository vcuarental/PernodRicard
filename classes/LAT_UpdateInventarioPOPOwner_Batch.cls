global class LAT_UpdateInventarioPOPOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
	
	String query;
	Map <Id, Id> accountNewOwner = new Map<Id, Id>();
	Set <Id> accounts = new Set <Id>();

	global LAT_UpdateInventarioPOPOwner_Batch(String headerId) {

		List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];

		for(LAT_MasiveOwnerLine__c line :lines){
			accounts.add(line.LAT_Account__c);
			accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
		}

		query = 'Select Id, ownerId, Client__c From LAT_InventoryPOP__c where Client__c in :accounts';

	}
	
	global LAT_UpdateInventarioPOPOwner_Batch(Map<Id, Lat_Account__c> mapLatAccount) {

		accounts = mapLatAccount.keySet();
		accountNewOwner = new Map<Id, Id>();

		for(Lat_Account__c latacc :mapLatAccount.values()){
			
			accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
		}

		query = 'Select Id, ownerId, Client__c From LAT_InventoryPOP__c where Client__c in :accounts';

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List <LAT_InventoryPOP__c> lat_pops = (List<LAT_InventoryPOP__c>)scope;
		
		for (LAT_InventoryPOP__c lat_pop : lat_pops) {
			
			lat_pop.ownerId = accountNewOwner.get(lat_pop.Client__c);
			
		}

		update lat_pops;
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}