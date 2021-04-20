/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
public with sharing class LAT_BR_VFC24_AccountInactivation_Test {

    @isTest
	static void testMethod1() { 
        Utils.setMigrationDoneTest(false);  
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(false);  
        ApexPages.StandardController con = new ApexPages.StandardController(acc);
        LAT_BR_VFC24_AccountInactivation controller = new LAT_BR_VFC24_AccountInactivation(con);
        controller.acc.Type = 'Vendas'; 
        controller.onLoad();
        
        controller.acc.Type = 'Outros';
            
        controller.onLoad();
        List <Account> returnList = [SELECT Id, Rating FROM Account WHERE id = :acc.Id LIMIT 1];
        //System.assertEquals('Cliente Inativo', returnList[0].Rating);
        controller.acc.Type = 'Vendas'; 
        controller.acc.Reason_for_Inactivation__c = 'Sem Compra há 12 meses';
        controller.cas.Description = 'Es un test.';
        controller.save();


        Test.stopTest();
	}

    //MIGRATED 21/11/2016
    @isTest
    static void testMethodB() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  
        ApexPages.StandardController con = new ApexPages.StandardController(acc);
        LAT_BR_VFC24_AccountInactivation controller = new LAT_BR_VFC24_AccountInactivation(con);
        controller.acc.Type = 'Vendas'; 
        controller.onLoad();
        
        controller.acc.Type = 'Outros';
            
        controller.onLoad();
        List <Account> returnList = [SELECT Id, Rating FROM Account WHERE id = :acc.Id LIMIT 1];
        //System.assertEquals('Cliente Inativo', returnList[0].Rating);
        controller.acc.Type = 'Vendas'; 
        controller.acc.Reason_for_Inactivation__c = 'Sem Compra há 12 meses';
        controller.latCase.LAT_Description__c = 'Es un test.';
        controller.save();


        Test.stopTest();
    }
}