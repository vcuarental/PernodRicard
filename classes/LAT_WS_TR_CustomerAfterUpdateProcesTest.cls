@isTest
public with sharing class LAT_WS_TR_CustomerAfterUpdateProcesTest {


  static testMethod void test1() {
    User userLat = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 1];
    System.runAs(userLat){
      Test.startTest();

      Account acc =  getAccountMX();
      acc.Status__c = 'Account to Review in JDE';
      acc.Client_code_AN8__c = null;
      insert acc;
      List <Account> accList = new List <Account>();
      accList.add(acc);
      LAT_WS_TR_CustomerAfterUpdateProcesses.submitCustomerForApprovalAR(accList);
      LAT_WS_TR_CustomerAfterUpdateProcesses.updateCustomerStatusToRegisteredBR(accList);//

      Test.stopTest();  
    }
    
  }

  static testMethod void test2() {
    Test.startTest();
      Account acc =  getAccountMX();
      User vendas = [SELECT Id FROM User WHERE Profile.Name = 'LAT_MX2_Vendedor' AND isActive = true limit 1];
      acc.OwnerId = vendas.Id;
      acc.Status__c = 'Account to Review in JDE';
      
      acc.Is_Interface_Process_AR__c = true;
      insert acc;

      Account acc2 = [SELECT Id, Name, Client_code_AN8__c FROM Account WHERE Id = :acc.Id];
      acc2.Client_code_AN8__c = null;
      List <Account> accList = new List <Account>();
      Map <Id, Account> accMap = new Map <Id, Account>();
      accList.add(acc);
      accMap.put(acc.Id, acc2);
      LAT_WS_TR_CustomerAfterUpdateProcesses.sendCustomerEmailMX(accList, accMap);

    Test.stopTest();  
  }

  static testMethod void test2B() {
     
    
      Test.startTest();  
      Account acc =  getAccountMX();
      User vendas = [SELECT Id FROM User WHERE (Profile.Name = 'LAT_MX2_Vendedor') AND isActive = true limit 1];
      acc.OwnerId = vendas.Id;
      acc.Status__c = 'Account to Review in JDE';
      
      acc.Is_Interface_Process_AR__c = true;
      
          insert acc;
      
          Account acc2 = [SELECT Id, Name, Client_code_AN8__c FROM Account WHERE Id = :acc.Id];
          acc2.Client_code_AN8__c = null;
          List <Account> accList = new List <Account>();
          Map <Id, Account> accMap = new Map <Id, Account>();
          accList.add(acc);
          accMap.put(acc.Id, acc2);
          LAT_WS_TR_CustomerAfterUpdateProcesses.sendCustomerEmailMX(accList, accMap);
      
    Test.stopTest();  
  }

  static Account getAccountMX() {
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = '12 Dias MX - Test',
            Internal_Id__c = '12-123-CRM-PT',
            CodUs__c = 'PT',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc;
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Client_code_AN8__c = '100',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        return acc;
  }
}