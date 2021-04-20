/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_ContractAutoNumberHandler Class.
  @Author:      IPC
  @History:     July 2014 - Created
*/
@isTest

private with sharing class EUR_CRM_DE_TestContractAutoNumber  {
    private static EUR_CRM_Auto_Number_Container__c autoNumber;
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    
    private static String autoNumberPrefix = 'TEST_';
    private static String contractRecordTypeDevName = 'EUR_DE_Contract';
    
    public static void dataInsert1(){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Auto_Number_Container__c', 'EUR_DE_Auto_Number_Container');
        autoNumber = new EUR_CRM_Auto_Number_Container__c();
        autoNumber.EUR_CRM_Auto_Number_Length__c = 10;
        autoNumber.EUR_CRM_Current_Count__c = 0;
        autoNumber.EUR_CRM_Number_Prefix__c = autoNumberPrefix;
        autoNumber.Name = contractRecordTypeDevName;
        insert autoNumber;
        system.assertNotEquals(autoNumber, null);
        
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;
        system.assertNotEquals(accountEU, null);
    }
    
    public static void dataInsert2(){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Auto_Number_Container__c', 'EUR_DE_Auto_Number_Container');
        autoNumber = new EUR_CRM_Auto_Number_Container__c();
        autoNumber.EUR_CRM_Auto_Number_Length__c = 10;
        autoNumber.EUR_CRM_Current_Count__c = 0;
        autoNumber.EUR_CRM_Number_Prefix__c = autoNumberPrefix;
        autoNumber.Name = contractRecordTypeDevName;
        insert autoNumber;
        system.assertNotEquals(autoNumber, null);
        
        //Create account
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, EUR_CRM_DE_TestClassUtilityHelper.DE_EUACCOUNT_ON_CONSUMERS_RECORD_TYPE)[0];
        insert accountEU;
        system.assertNotEquals(accountEU, null);
    }

    
    static testMethod void testMethod1(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        test.StartTest();
        
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            dataInsert1();
            contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
            insert contract;
        }
        test.stopTest();
    }
    /*
    static testMethod void testMethod2(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        test.StartTest();
        
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            dataInsert2();
            contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
            insert contract;
        }
        test.stopTest();
    }
    */
}