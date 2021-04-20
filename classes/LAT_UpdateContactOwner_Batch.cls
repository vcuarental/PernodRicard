global class LAT_UpdateContactOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
		
	String query;
	Map <Id, Id> accountNewOwner = new Map<Id, Id>();
	Set <Id> accounts = new Set <Id>();
	
	global LAT_UpdateContactOwner_Batch(String headerId) {


		List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];
	

		for(LAT_MasiveOwnerLine__c line :lines){
			accounts.add(line.LAT_Account__c);
			accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
		}

		query = 'Select Id, ownerId, AccountId From Contact where AccountId in :accounts';

	}

	global LAT_UpdateContactOwner_Batch(Map<Id, Lat_Account__c> mapLatAccount) {

		accounts = mapLatAccount.keySet();
		accountNewOwner = new Map<Id, Id>();

		for(Lat_Account__c latacc :mapLatAccount.values()){
			
			accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
		}
		
		query = 'Select Id, ownerId, AccountId From Contact where AccountId in :accounts';

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List <Contact> contacts = (List<Contact>)scope;
		
		for (Contact myContact : contacts) {
			
			myContact.ownerId = accountNewOwner.get(myContact.AccountId);
			
		}

		update contacts;
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}