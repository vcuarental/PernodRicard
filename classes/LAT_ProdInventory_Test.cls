@isTest
private class LAT_ProdInventory_Test {
	
	@isTest static void updateInventoryAmount () {
		String idPOP = '';
		LAT_ProdInventory__c prodInv = new LAT_ProdInventory__c();
		prodInv.AmountLeft__c = Integer.valueOf('200');
		prodInv.Delivered__c = Integer.valueOf('300');
		prodInv.Material__c = productoPOPCreator().id;
		prodInv.Inventario_POP__c = invPop().id;
    
    insert prodInv;
    List <LAT_InventoryPOP__c> ListProdInv = [Select client__c from LAT_InventoryPOP__c];
    for (LAT_InventoryPOP__c prodInvIn : ListProdInv) {
    	idPOP = prodInvIn.client__c;
    }
    prodInv.AmountLeft__c = Integer.valueOf('100');
    LAT_ClientAmountPOP__c clientAmountPOP = new LAT_ClientAmountPOP__c();
    clientAmountPOP.client__c = idPOP;
    clientAmountPOP.product__c = prodInv.Material__c;
    clientAmountPOP.oldAmount__c = Integer.valueOf('100');
    clientAmountPOP.actualAmount__c = Integer.valueOf('200');
    clientAmountPOP.clientMaterial__c = 'ABC';
    insert clientAmountPOP;
    update prodInv;

	}
	
	@isTest static void constructorTest(){

  	LAT_ProdInventory prodInv = new LAT_ProdInventory ();
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