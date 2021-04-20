/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que cria um objeto Contrato para ser usado em classes de testes
* NAME: ContractObjectTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 09/11/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
*******************************************************************************/
@isTest
public with sharing class ContractObjectTest {
  
  static testMethod void myUnitTest() {
    //Cria novo usuario.      
    User usuario = new User();
    usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
    insert usuario;

    LAT_Contract__c lContrato = new LAT_Contract__c();

    system.runas(usuario){

    UDC__c regional = new UDC__c();
    regional.CodDefUsuario__c = '1';
    regional.CodProd__c     = '01';
    regional.CodUs__c       = '01';
    regional.Internal_Id__c = '01-01';
    regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
    insert regional;
      
    Account lAcc = new Account();
    lAcc.name = 'Teste';
    lAcc.Corporate_Name__c = 'Testando';
    lAcc.Status__c = 'Cliente cadastrado no JDE';
    lAcc.Rating = 'Cliente com contrato';
    lAcc.Client_code_AN8__c = '123';
    lAcc.CNPJ__c = '54140509000169';
    lAcc.Regional__c = regional.id;
    lAcc.Channel__c = 'Off Trade';
    lAcc.Revenue_UF__c = '6';
    lAcc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade' );
    insert lAcc;
    

    lContrato.Account__c = lAcc.id;
    lContrato.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade' );
    lContrato.OwnerId = usuario.Id;
    insert lContrato;
    
    lContrato.Status__c = 'Ativo';
    update lContrato;
    
    }
  }
  
}