@isTest
private class LAT_ProdInventory_Trigger_Test {
	
	@isTest static void testTriggerProdInv() {

		LAT_ProdInventory__c prodInv = new LAT_ProdInventory__c();
		prodInv.AmountLeft__c = Integer.valueOf('200');
		prodInv.Delivered__c = Integer.valueOf('300');
		prodInv.Material__c = productoPOPCreator().id;
		prodInv.Inventario_POP__c = invPop().id;
    
    insert prodInv;
    prodInv.AmountLeft__c = Integer.valueOf('100');
    update prodInv;

	}
	public static LAT_Produto_POP__c productoPOPCreator(){
        
    LAT_Produto_POP__c prod = new LAT_Produto_POP__c();
    prod.Sku__c = '12';
    prod.name = 'ABC';
    prod.Evidence__c = true;
    prod.Parent_Product__c = 'ABC';
    prod.Inventory__c = false;
   
    insert prod;
    return prod;
  }

  public static LAT_InventoryPOP__c invPOP(){
		LAT_InventoryPOP__c invPOP = new LAT_InventoryPOP__c();
  	Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();

  	insert acc;

  	invPOP.Client__c = acc.id;

  	insert invPOP;
  	return invPOP;
  }
}