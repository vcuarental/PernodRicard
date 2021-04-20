global class LAT_MX_AccountIntegrateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
	
	Map<String, Account> accountMap;
	String query;
	
	global LAT_MX_AccountIntegrateBatch(Map<String, Account> amap, String pQuery) {
		accountMap = amap;
		query = pQuery;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Account> lstAccounts = (List<Account>)scope;

		for(Account acc: lstAccounts){
			if(accountMap.get(acc.id) != null){
				acc = accountMap.get(acc.id);
				acc.Is_interface_Process_AR__c = true;
				acc.Status__c = 'Customer Sent to JDE - Please Wait';
				LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDESync(acc);	
			}
		}
		update lstAccounts;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}