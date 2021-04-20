global class LAT_UpdateLAT_CaseOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
	
	String query;
	Map <Id, Id> accountNewOwner = new Map<Id, Id>();
	Set <Id> accounts = new Set <Id>();
	Set <String> groupsNames = new Set<String>{'Administracao_de_Vendas', 'Credito_e_Cobranca', 'Customer_service', 'Planejamento_comercial', 'Regional_Sao_Paulo', 'LAT_BR_ProcessSupervisor', 'Controladoria'};
	Set <Id> groupsIds = new Set<Id>();

	global LAT_UpdateLAT_CaseOwner_Batch(String headerId) {


		List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];
	

		for(LAT_MasiveOwnerLine__c line :lines){
			accounts.add(line.LAT_Account__c);
			accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
		}

		for(Group grupo : [Select Id From Group Where Type = 'Queue' AND developername in :groupsNames]){
			groupsIds.add(grupo.Id);
		}

		query = 'Select Id, ownerId, LAT_Account__c From LAT_Case__c where ownerId not in :groupsIds and LAT_Account__c in :accounts';

	}

	global LAT_UpdateLAT_CaseOwner_Batch(Map<Id, Lat_Account__c> mapLatAccount) {

		accounts = mapLatAccount.keySet();
		accountNewOwner = new Map<Id, Id>();

		for(Lat_Account__c latacc :mapLatAccount.values()){
			
			accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
		}
		
		query = 'Select Id, ownerId, LAT_Account__c From LAT_Case__c where ownerId not in :groupsIds and LAT_Account__c in :accounts';

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List <LAT_Case__c> lat_cases = (List<LAT_Case__c>)scope;
		
		for (LAT_Case__c myCase : lat_cases) {
			
			myCase.ownerId = accountNewOwner.get(myCase.LAT_Account__c);
			
		}

		update lat_cases;
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}