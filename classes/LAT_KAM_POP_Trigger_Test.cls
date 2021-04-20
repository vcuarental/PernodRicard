@isTest
private class LAT_KAM_POP_Trigger_Test {
	
	@isTest static void KamPOPTriggerTest() {
 		
 		LAT_KAMPOP__c kam = KamPOPCreator();
 		update kam;
 	}

 	public static LAT_Produto_POP__c productoPOPCreator(){
		
		LAT_Produto_POP__c prod = new LAT_Produto_POP__c();
		prod.Sku__c = '12';
		prod.name = 'ABC';
		prod.Evidence__c = true;
		prod.Parent_Product__c = 'ABC';
		prod.Inventory__c = true;
		insert prod;
		return prod;
	}

	public static LAT_KAMPOP__c KamPOPCreator(){
		
		LAT_RegionalPOP__c reg = new LAT_RegionalPOP__c();
		reg.product__c = productoPOPCreator().id;
		reg.Amount__c = Integer.valueOf('5000');
		insert reg;
		LAT_KAMPOP__c kamPop = new LAT_KAMPOP__c();
		kamPop.Amount__c = Integer.valueOf('300');
		kamPop.RegionalPOP__c = reg.id;
		//kamPop.Client__c = accountCreator().id;
		insert kamPop;
		return kamPOP;
	}

	public static Account accountCreator(){
		
		Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    insert Acc;
    return Acc;
	}
}