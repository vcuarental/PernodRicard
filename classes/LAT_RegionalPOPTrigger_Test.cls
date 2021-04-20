/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
@isTest
private class LAT_RegionalPOPTrigger_Test {
	
	@isTest static void RegionalPopTriggerTest() {
		
		LAT_RegionalPOP__c reg = 	regionalPOPCreator();
		List<Task> listTask = [Select id from Task];
		System.assertEquals(listTask.size(), 1);
		System.assertEquals(reg.ownerId,reg.Regional_Supervisor_POP__r.Supervisor__c);
	}
	@isTest static void RegionalPopTriggerTestB() {
		
		LAT_RegionalPOP__c reg = 	regionalPOPCreatorB();
		List<Task> listTask = [Select id from Task];
		System.assertEquals(listTask.size(), 1);
		System.assertEquals(reg.ownerId,reg.Regional_Supervisor_POP__r.Supervisor__c);
	}

	public static LAT_RegionalPOP__c regionalPOPCreator(){
	
		LAT_RegionalSupervisor__c sup = new LAT_RegionalSupervisor__c();
 		User a = TestFactory.createUserWithProfile('admin', 'LAT_MX_System Administrator');
 		insert a;
		sup.Supervisor__c = a.id;
		insert sup;
		LAT_RegionalPOP__c reg = new LAT_RegionalPOP__c();
		reg.product__c = productoPOPCreator().id;
		reg.Regional_Supervisor_POP__c = sup.id;
		reg.Amount__c = Integer.valueOf('200');
		insert reg;
		return reg;	
	}

	public static LAT_RegionalPOP__c regionalPOPCreatorB(){
	
		LAT_RegionalSupervisor__c sup = new LAT_RegionalSupervisor__c();
 		User a = TestFactory.createUserWithProfile('admin', 'LAT_SystemAdministrator');
 		insert a;
		sup.Supervisor__c = a.id;
		insert sup;
		LAT_RegionalPOP__c reg = new LAT_RegionalPOP__c();
		reg.product__c = productoPOPCreator().id;
		reg.Regional_Supervisor_POP__c = sup.id;
		reg.Amount__c = Integer.valueOf('200');
		insert reg;
		return reg;	
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
}