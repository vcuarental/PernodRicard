/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da trigger CasoAtualizaCamposContrato
* NAME: CasoAtualizaCamposContratoTest.cls
* AUTHOR: CARLOS CARVALHO                             DATE: 28/09/2012
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                             DATE: 09/01/2013 
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
private class CasoAtualizaCamposContratoTest {

    static testMethod void myUnitTest() {
            
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        Profile p =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];
        usuario.profile = p;
        insert usuario;
        
        System.runAs(usuario){
            
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
          
          insert caso;
          /*
          caso = new Case();
          caso.OwnerId = usuario.id;
          caso.RecordTypeId = [select id,Name from RecordType where SobjectType='Case' and Name='Inserir o Tipo de Verba' Limit 1].id;  
          caso.LAT_Contract__c = Lc.Id;
          caso.Status = 'Aprovado';
          caso.AccountId = Lc.Account__c;
          caso.Integration_Status__c = 'Reservado';
          caso.Inquiry_held__c = true;
          caso.Amount_Type__c = 'Bonificação';
          caso.Purposes_Action__c = 'Aniversário';
          
          insert caso; 
          */
      }
  }
  //MIGRATED 21/11/2016
  static testMethod void myUnitTestLATCase() {
            
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
        Profile p =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];
        usuario.profile = p;
        insert usuario;
        
        system.debug('Funciona lo del pirata? ' +   p.id);
        System.runAs(usuario){
            
          Account Acc = new Account();      
          Acc.Name = 'Teste';
          Acc.Rating = 'Cliente';
          Acc.Status__c = 'Cliente cadastrado no JDE';
          Acc.CNPJ__c = '48843971000120';
          Acc.Segmentation_Type_on_trade__c = 'Restaurante';
          acc.Rating = 'Cliente';
            
          
          insert Acc; 
          system.debug('El acc ' +  acc);
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
          Test.startTest();
          
          LAT_Case__c caso = new LAT_Case__c();
          caso.OwnerId = usuario.id;
          caso.RecordTypeId = [select id,Name from RecordType where SobjectType='LAT_Case__c' and Name='Gerar D.A no sistema ME' Limit 1].id; 
          caso.LAT_Contract__c = Lc.Id;
          caso.LAT_Status__c = 'Fechado e resolvido';
          caso.LAT_Account__c = Lc.Account__c;
          caso.LAT_IntegrationStatus__c = 'Reservado';
          caso.LAT_Inquiryheld__c = true;
          
          insert caso;

          update caso;
          LAT_Case__c caso2 = new LAT_Case__c();
          caso2.OwnerId = usuario.id;
          caso2.RecordTypeId = [select id,Name from RecordType where SobjectType='LAT_Case__c' and Name='Gerar D.A no sistema ME' Limit 1].id; 
          caso2.LAT_Contract__c = Lc.Id;
          caso2.LAT_Status__c = 'Novo';
          caso2.LAT_Account__c = Lc.Account__c;
          caso2.LAT_IntegrationStatus__c = 'Reservado';
          caso2.LAT_Inquiryheld__c = true;
          
          insert caso2;
          caso2.LAT_Status__c = 'Fechado e resolvido';
          //caso2.LAT_IsClosed__c = true;
          update caso2;
          /*
          caso = new Case();
          caso.OwnerId = usuario.id;
          caso.RecordTypeId = [select id,Name from RecordType where SobjectType='Case' and Name='Inserir o Tipo de Verba' Limit 1].id;  
          caso.LAT_Contract__c = Lc.Id;
          caso.Status = 'Aprovado';
          caso.AccountId = Lc.Account__c;
          caso.Integration_Status__c = 'Reservado';
          caso.Inquiry_held__c = true;
          caso.Amount_Type__c = 'Bonificação';
          caso.Purposes_Action__c = 'Aniversário';
          
          insert caso; 
          */
          Test.stopTest();
      }
  }
}