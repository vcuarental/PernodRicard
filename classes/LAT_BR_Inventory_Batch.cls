global class LAT_BR_Inventory_Batch implements Database.Batchable<sObject>,Database.Stateful{

	global LAT_BR_Inventory_Batch() {

	} 

	global Database.QueryLocator start(Database.BatchableContext BC) {

		String query = 'Select id from Account where id in (\'\'';
		 for(AggregateResult ar : [Select client__c from LAT_ClientAmountPOP__c group by client__c]){
        	query += ',\'' + ar.get('client__c') + '\'';
        }
        query += ')';

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Savepoint sp = Database.setSavepoint();
		try{
			List <Account> accounts = (List<Account>)scope;
			List<String> accountIdList = new List<String>();

			for(Account acc : accounts){
				accountIdList.add(acc.id);
			}
			
			

			Map<String, List<LAT_ProdInventory__c>> inventoryMap = new Map<String, List<LAT_ProdInventory__c>>();
			Map<String, Account> owners = new Map<String, Account>();
			for(LAT_ClientAmountPOP__c cli: [Select id,client__c,client__r.name,client__r.ownerId,client__r.owner.Name,actualAmount__c,product__c from LAT_ClientAmountPOP__c where actualAmount__c > 0 and product__r.Inventory__c = TRUE and client__c in : accountIdList]){
				owners.put(cli.client__c, cli.Client__r);

				if(inventoryMap.get(cli.client__c) == null){
					LAT_InventoryPOP__c Inv = new LAT_InventoryPOP__c(client__c = cli.client__c);
					LAT_ProdInventory__c pInv = new LAT_ProdInventory__c(Material__c = cli.product__c, delivered__c = cli.actualAmount__c);

					inventoryMap.put(cli.client__c,new List<LAT_ProdInventory__c>{pInv});
				}else{
					List<LAT_ProdInventory__c> tMap = inventoryMap.get(cli.client__c);
					tmap.add(new LAT_ProdInventory__c(Material__c = cli.product__c, delivered__c = cli.actualAmount__c));
				}
			}


			Map<String, LAT_InventoryPOP__c> inventories = new Map<String, LAT_InventoryPOP__c>();
			for(String cli : inventoryMap.keyset()){
				LAT_InventoryPOP__c inv = new LAT_InventoryPOP__c(client__c = cli, ownerId = owners.get(cli).ownerId);
				inventories.put(cli,inv);
			}
			insert inventories.values();

			List<LAT_ProdInventory__c> lineas = new List<LAT_ProdInventory__c>();
			Integer days = 15;

			String[] tdays = LAT_GeneralConfigDao.getValueAsStringArray('POP_INVENTORY_DAYS', ' ');
			if(tdays != null && tdays.size()>0)days = Integer.valueOf(tdays[0]);


			List<Task> insertList = new List<Task>();
				List<ConnectApi.BatchInput> posts = new List<ConnectApi.BatchInput>();
			for(String cli : inventories.keySet()){

					Task t = LAT_ProcessesTaks.createTask(inventories.get(cli).id, inventories.get(cli).ownerID, Label.LAT_Processes_013,Label.LAT_Processes_014.replace('{0}',owners.get(cli).Name).replaceAll('</br>','\n'), Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),days, 'POP-Inventario');
				insertList.add(t);

					ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(inventories.get(cli).ownerID,new List<String>(), LAbel.LAT_Processes_015,inventories.get(cli).id);
				if(post != null)posts.add(post);

				for(LAT_ProdInventory__c linea : inventoryMap.get(cli)){
					linea.Inventario_POP__c = inventories.get(cli).id;
					lineas.add(linea);
				}
			}
			insert lineas;

			LAT_ProcessesNotifications.post(posts);
			LAT_ProcessesTaks.insertAndNotificate(insertList);
		}catch(exception e){
	   		Database.rollback(sp);
	   		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error ' + e.getMessage()));
	   	}
	
	}

	global void finish(Database.BatchableContext BC) {

	}
}