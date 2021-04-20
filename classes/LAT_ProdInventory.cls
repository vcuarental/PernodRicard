public with sharing class LAT_ProdInventory {
	public LAT_ProdInventory() {
		
	}


	public static void updateInventoryAmount(Map<id,LAT_ProdInventory__c> newMap, Map<id,LAT_ProdInventory__c> oldMap){

		Map<id,LAT_ProdInventory__c> tmpNewMap = new Map<id,LAT_ProdInventory__c>([select id,Inventario_POP__c, Inventario_POP__r.Client__c,Material__c,Delivered__c,AmountLeft__c from LAT_ProdInventory__c where id in: newMap.keySet()]);

		Map<String, LAT_ClientAmountPOP__c> materialClienteLst = new Map<String, LAT_ClientAmountPOP__c>();
		List<String> materialClientes = new List<String>();

		for(LAT_ProdInventory__c clP : tmpNewMap.values()){
			materialClientes.add(clp.Inventario_POP__r.Client__c + '' + clp.Material__c);
		}

		for(LAT_ClientAmountPOP__c cli : [Select id,clientMaterial__c,product__c,client__c,actualAmount__c,oldAmount__c from LAT_ClientAmountPOP__c where clientMaterial__c in :materialClientes]){
			materialClienteLst.put(cli.clientMaterial__c, cli);
		}


		for(String pid : tmpNewMap.keySet()){

			if(tmpNewMap.get(pid).AmountLeft__c != oldMap.get(pid).AmountLeft__c  && tmpNewMap.get(pid).AmountLeft__c != null){
				String key = tmpNewMap.get(pid).Inventario_POP__r.Client__c + '' + tmpNewMap.get(pid).Material__c;
				if(materialClienteLst.get(key) != null){
					materialClienteLst.get(key).actualAmount__c = tmpNewMap.get(pid).AmountLeft__c;
					materialClienteLst.get(key).oldAmount__c = tmpNewMap.get(pid).Delivered__c;
				}
			}
		}

		update materialClienteLst.values();
	}


}