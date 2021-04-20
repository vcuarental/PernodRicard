@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe BalanceCheckInterface
* NAME: BalanceCheckInterfaceTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 25/09/2012
*
*
* MAINTENANCE: INSERIDO MÉTODO RecordTypeForTest.
* AUTHOR: CARLOS CARVALHO                           DATE: 14/01/2013
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
private class BalanceCheckInterfaceTest {
    @isTest
    public static void myUnitTest() {
      User usuario = new User();
      Utils.setMigrationDoneTest(false);  
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        Profile p =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];
        usuario.profile = p;
        insert usuario;
        
        System.runAs(usuario){
            Utils.setMigrationDoneTest(false);  
          Account Acc = new Account();      
          Acc.Name = 'Teste';
          Acc.Rating = 'Cliente';
          Acc.Status__c = 'Cliente cadastrado no JDE';
          Acc.CNPJ__c = '48843971000120';
          Acc.Segmentation_Type_on_trade__c = 'Restaurante';
          acc.Rating = 'Cliente';
            
          
          insert Acc; 

          LAT_Contract__c Lc = new LAT_Contract__c();        
          Lc.OwnerId = usuario.Id;        
          Lc.RecordTypeId = [select id,Name from RecordType where SobjectType='LAT_Contract__c' and Name='Assinatura de contrato - Off Trade ativo' Limit 1].id;
          Lc.Account__c = Acc.Id;        
          Lc.Status__c = 'Em Elaboração';        
          Lc.ROI_Comentarios_Negativo__c = 'Teste';        
          Lc.StartDate__c = System.today();        
          Lc.Gerente_Regional__c = Usuario.Id;
          Lc.Gerente__c = Usuario.Id;
          Lc.Gerente_de_area__c = Usuario.Id;  

          insert Lc;
          
          Case caso = new Case();
          caso.OwnerId = usuario.id;
          caso.RecordTypeId = [select id,Name from RecordType where SobjectType='Case' and Name='Gerar D.A no sistema ME' Limit 1].id; 
          caso.LAT_Contract__c = Lc.Id;
          caso.Status = 'Fechado e resolvido';
          caso.AccountId = Lc.Account__c;
          caso.Integration_Status__c = 'Reservado';
          caso.Inquiry_held__c = true;
          caso.WF_Type__c  = 'CS';
          caso.DA_Number__c  = 127;
          
          insert caso;
          BalanceCheckInterface.BalanceCheckInvoke( String.valueOf( caso.Id ));
       
      }
    }
    @isTest
    public static void myUnitTest2()
    { 
      BalanceCheck.PMEWS010_Execute_element le = new BalanceCheck.PMEWS010_Execute_element();
      le.Domnro = 0;
      le.Empcod = 0;
      le.Paicod = 0;
      le.Tdocod = '';
      le.User_x = '';
    }

    //MIGRATED 21/11/2016
    @isTest
    public static void myUnitTestB() {
      User usuario = new User();
      Utils.setMigrationDoneTest(true);  
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        Profile p =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];
        usuario.profile = p;
        insert usuario;
        
        System.runAs(usuario){
            Utils.setMigrationDoneTest(true);  
          Account Acc = new Account();      
          Acc.Name = 'Teste';
          Acc.Rating = 'Cliente';
          Acc.Status__c = 'Cliente cadastrado no JDE';
          Acc.CNPJ__c = '48843971000120';
          Acc.Segmentation_Type_on_trade__c = 'Restaurante';
          acc.Rating = 'Cliente';
            
          
          insert Acc; 
          Test.startTest();
          Utils.setMigrationDoneTest(true); 

          LAT_Contract__c Lc = new LAT_Contract__c();        
          Lc.OwnerId = usuario.Id;        
          Lc.RecordTypeId = [select id,Name from RecordType where SobjectType='LAT_Contract__c' and Name='Assinatura de contrato - Off Trade ativo' Limit 1].id;
          Lc.Account__c = Acc.Id;        
          Lc.Status__c = 'Em Elaboração';        
          Lc.ROI_Comentarios_Negativo__c = 'Teste';        
          Lc.StartDate__c = System.today();        
          Lc.Gerente_Regional__c = Usuario.Id;
          Lc.Gerente__c = Usuario.Id;
          Lc.Gerente_de_area__c = Usuario.Id;  

          insert Lc;
          
          LAT_Case__c caso = new LAT_Case__c();
          caso.OwnerId = usuario.id;
          caso.RecordTypeId = [select id,Name from RecordType where SobjectType='LAT_Case__c' and Name='Gerar D.A no sistema ME' Limit 1].id; 
          caso.LAT_Contract__c = Lc.Id;
          caso.LAT_Status__c = 'Fechado e resolvido';
          caso.LAT_Account__c = Lc.Account__c;
          caso.LAT_IntegrationStatus__c = 'Reservado';
          caso.LAT_Inquiryheld__c = true;
          caso.LAT_WFType__c  = 'CS';
          caso.LAT_DANumber__c  = 127;
          
          insert caso;
          BalanceCheckInterface.BalanceCheckInvoke( String.valueOf( caso.Id ));
          Test.stopTest();
      }
    }

}