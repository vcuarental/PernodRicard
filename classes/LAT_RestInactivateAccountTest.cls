/**
 * test for the inactivate button, also used from ws in LAT_RestInactivateAccount
 */
@isTest
public with sharing class LAT_RestInactivateAccountTest {


	private static final string LONG_STRING_TO_FAIL_DML = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+ 
	'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
	static testMethod void testMethodNoCadastrado() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Status__c = 'no cadastrado';
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  


        LAT_RestInactivateAccount.sendAccountInactivation(acc.Id, '', '');

        Test.stopTest();
    }

    static testMethod void testMethodJDEcadastrado() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Status__c = 'Cliente cadastrado no JDE';
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  


        LAT_RestInactivateAccount.sendAccountInactivation(acc.Id, 'test', 'test');

        Test.stopTest();
    }

    static testMethod void testMethodcrmcadastrado() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Status__c = 'Cliente cadastrado no CRM';
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  


        LAT_RestInactivateAccount.sendAccountInactivation(acc.Id, 'test', 'test');

        Test.stopTest();
    }

    static testMethod void testMethodJDEcadastradoNoData() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Status__c = 'Cliente cadastrado no JDE';
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  


        LAT_RestInactivateAccount.sendAccountInactivation(acc.Id, '', ''); 

        Test.stopTest();
    }

    static testMethod void testMethodException() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Status__c = 'Cliente cadastrado no CRM';
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  


        LAT_RestInactivateAccount.sendAccountInactivation(acc.Id, LONG_STRING_TO_FAIL_DML, LONG_STRING_TO_FAIL_DML);

        Test.stopTest();
    }
}