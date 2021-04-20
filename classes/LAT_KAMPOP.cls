public with sharing class LAT_KAMPOP {
	public LAT_KAMPOP() {

	}

	public static void kamNotification(Map<Id,LAT_KAMPOP__c> kampops){

		Map<Id,LAT_KAMPOP__c> tmpKampops = new Map<Id,LAT_KAMPOP__c>([Select id,RegionalPOP__r.product__r.SKU__c,RegionalPOP__r.product__r.name from LAT_KAMPOP__c where id in: kampops.keyset()]);
		List<ConnectApi.BatchInput> posts = new List<ConnectApi.BatchInput>();
		String groupId = '';
		String[] groups = LAT_GeneralConfigDao.getValueAsStringArray('KAM_POP_CHATTER_GROUP', ' ');
		if(groups != null && groups.size()>0)groupId = groups[0];

		String reportId = '';
		String[] tReport = LAT_GeneralConfigDao.getValueAsStringArray('KAM_POP_REPORT', ' ');
		if(tReport != null && tReport.size()>0)reportId = tReport[0];


		for(LAT_KAMPOP__c kamPOP : kampops.values()){
			ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>{kamPOP.kam__c}, Label.LAT_Processes_008.replace('{0}',tmpKampops.get(kamPOP.id).RegionalPOP__r.product__r.SKU__c + ' - '+ tmpKampops.get(kamPOP.id).RegionalPOP__r.product__r.name).replace('{1}',tmpKampops.get(kamPOP.id).RegionalPOP__r.product__r.SKU__c).replaceAll('</br>','\n'),reportId);
			if(post != null)posts.add(post);
		}
		LAT_ProcessesNotifications.post(posts);
	}

	public static void shareRecords(Map<Id,LAT_KAMPOP__c> kampops){
		List<LAT_RegionalPOP__Share> toUpdate= new List<LAT_RegionalPOP__Share>();
		Set<String> setToUpdate = new Set<String>();

		for(LAT_KAMPOP__c kamPOP : kampops.values()){
			if(!setToUpdate.contains(kamPOP.kam__c + '' +kamPOP.RegionalPOP__c)){
				LAT_RegionalPOP__Share jobShr  = new LAT_RegionalPOP__Share();
	       		jobShr.ParentId = kamPOP.RegionalPOP__c;
	       		jobShr.UserOrGroupId = kamPOP.kam__c;
	       		jobShr.AccessLevel = 'Edit';
	       		toUpdate.add(jobShr);
	       		setToUpdate.add(kamPOP.kam__c + '' +kamPOP.RegionalPOP__c);
       		}
		}

		try{
			Database.insert(toUpdate,false);
		}catch(exception ex){
			LAT_DebugUtil debugUtil = new LAT_DebugUtil();
            debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
            debugUtil.setOrigin('MATERIAL POP');
            debugUtil.insertDebug();
		}


	}

	public static void checkKAMPOP(List<LAT_KAMPOP__c> kampops){
		List<String> regionals = new List<String>();
		List<String> clients = new List<String>();
		Map<String,List<LAT_KAMPOP__c>> regionalsMap = new MAp<String, List<LAT_KAMPOP__c>>();
		Map<String,String> clientsMap = new MAp<String,String>();

		for(LAT_KAMPOP__c kam : kampops){
			regionals.add(kam.RegionalPOP__c);
		}

		for(LAT_RegionalPOP__c regionalPOP : [Select id,(Select id,KAM__c from KAMPOP__r) from LAT_RegionalPOP__c where id in: regionals]){
			regionalsMap.put(regionalPOP.id, regionalPOP.KAMPOP__r);
		}

		for (LAT_KAMPOP__c kamToInsert : kampops) {
			for(LAT_KAMPOP__c kamPOP : regionalsMap.get(kamToInsert.RegionalPOP__c)){
				if(kamToInsert.KAM__c == kamPOP.KAM__c){
					kamToInsert.addError(Label.LAT_Processes_004);
					break;
				}
			}
		}
	}

	public static void checkNegativeAmount(Map<Id,LAT_KAMPOP__c> kampops, Map<Id,LAT_KAMPOP__c> oldkampops){
		Map<Id,LAT_KAMPOP__c> tmpKams = new Map<Id,LAT_KAMPOP__c>([Select id, kam__r.managerId from LAT_KAMPOP__c where id in: kampops.keyset()]);
		List<LAT_ProcessesEmails.emailMsg> toSend = new List<LAT_ProcessesEmails.emailMsg>();

		for(String tid :  kampops.keyset()){
			if(oldkampops.get(tid).PlanningLeft__c >= 0 && kampops.get(tid).PlanningLeft__c < 0){
				LAT_ProcessesEmails.emailMsg tmp = new LAT_ProcessesEmails.emailMsg(new List<String>{kampops.get(tid).kam__c,tmpKams.get(tid).kam__r.managerId },Label.LAT_Processes_007, Label.LAT_Processes_006.replace('{0}', URL.getSalesforceBaseUrl().toExternalForm() + '/' + tid));
				toSend.add(tmp);
			}
		}
		system.debug('444444 ' + toSend);
		if(toSend.size() > 0)LAT_ProcessesEmails.sendEmail(toSend);

	}




   /*public static void runInventory(){
   		Savepoint sp = Database.setSavepoint();
		try{
   			Map<String, List<LAT_ProdInventory__c>> inventoryMap = new Map<String, List<LAT_ProdInventory__c>>();
	   		Map<String, Account> owners = new Map<String, Account>();

	   		for(LAT_ClientAmountPOP__c cli: [Select id,client__c,client__r.name,client__r.ownerId,client__r.owner.Name,actualAmount__c,product__c from LAT_ClientAmountPOP__c where actualAmount__c >0 and product__r.Inventory__c = TRUE]){
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
   }*/
   public static void runInventory(){
   		LAT_BR_Inventory_Batch tlb = new LAT_BR_Inventory_Batch();
    	Database.executeBatch(tlb, 100);

   }


}