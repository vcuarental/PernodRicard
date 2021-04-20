global class LAT_UpdateLAT_OpportunityOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
	
	String query;
	Map <Id, Id> accountNewOwner = new Map<Id, Id>();
	Set <Id> accounts = new Set <Id>();

	global LAT_UpdateLAT_OpportunityOwner_Batch(String headerId) {


		List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];
	

		for(LAT_MasiveOwnerLine__c line :lines){
			accounts.add(line.LAT_Account__c);
			accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
		}

		query = 'Select Id, ownerId, LAT_Account__c From LAT_Opportunity__c where LAT_Account__c in :accounts';

	}

	global LAT_UpdateLAT_OpportunityOwner_Batch(Map<Id, Lat_Account__c> mapLatAccount) {
		System.debug('%%%% Entramos en  LAT_UpdateLAT_OpportunityOwner_Batch mapLatAccount: ' + mapLatAccount);
		accounts = mapLatAccount.keySet();
		accountNewOwner = new Map<Id, Id>();

		for(Lat_Account__c latacc :mapLatAccount.values()){
			
			accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
		}

		query = 'Select Id, ownerId, LAT_Account__c From LAT_Opportunity__c where LAT_Account__c in :accounts';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug('%%%% scope.size() : ' + scope.size());
   		List <LAT_Opportunity__c> lat_opps = (List<LAT_Opportunity__c>)scope;
		
		for (LAT_Opportunity__c opp : lat_opps) {
			
			opp.ownerId = accountNewOwner.get(opp.LAT_Account__c);
	
		}
		if(lat_opps.size() >0 )
			update lat_opps;

		System.debug('%%%%% terminamos');
	
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('%%%%% en el finish');
	}
	
}