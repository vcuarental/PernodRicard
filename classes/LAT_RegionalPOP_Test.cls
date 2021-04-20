/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
@isTest(SeeAllData=false)
private class LAT_RegionalPOP_Test {
	
	@isTest static void UpdateOwnerTest(){	

		LAT_RegionalPOP__c reg = regionalPOPCreator();
		system.assertNotEquals(reg.Regional_Supervisor_POP__c,reg.ownerId);
	}
	@isTest static void UpdateOwnerTestB(){	

		LAT_RegionalPOP__c reg = regionalPOPCreatorB();
		system.assertNotEquals(reg.Regional_Supervisor_POP__c,reg.ownerId);
	}

	@isTest static void notificationTaskTest(){

		LAT_RegionalPOP__c reg = regionalPOPCreator();
		update reg;
		List<task> taskList = [SELECT id from Task where whatId =: reg.id];
		System.assertEquals(1,taskList.size());
	}


	@isTest static void notificationTaskTestB(){

		LAT_RegionalPOP__c reg = regionalPOPCreatorB();
		update reg;
		List<task> taskList = [SELECT id from Task where whatId =: reg.id];
		System.assertEquals(1,taskList.size());
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