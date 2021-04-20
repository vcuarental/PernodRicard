/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da trigger ContratoAprovado
* NAME: ContratoAprovadoTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 02/10/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                               DATE: 14/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
*******************************************************************************/
@isTest (seeAllData=true)
private class ContratoAprovadoTest {
  
  static testMethod void myUnitTest() 
  {
     //Cria Regional
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        UDC__c regional = new UDC__c(
         CodDefUsuario__c = '2',
         CodProd__c     = '01',
         CodUs__c     = '01',
         Internal_Id__c   = '01-01',
         RecordTypeId = idRecTypeUdc
       );
        insert regional;
        
        //Cria novo Account. 
        Account acc = new Account(
         Name = 'Conta teste Trigger',
         CNPJ__c = '48843971000120',
         Type = 'Outros',
         Status__c = 'Cliente cadastrado no JDE',
         Agency__c = '000',
         Checking_account__c = '000',
         Current_account__c = '0',
         Corporate_Name__c = 'Teste',
         Regional__c = regional.id,
         Channel_Type__c = 'Indireto',
         RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
       );
        insert acc;
        
        LAT_Contract__c lContract = new LAT_Contract__c(
         Account__c = acc.Id,
         Status__c = 'Em elaboração',
         StartDate__c = System.today(),
         ContractTerm__c = 12,
         Status_do_processo__c='Estudo em elaboração', 
         RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato'),
         ROI_Comentarios_Negativo__c = 'teste'
        );
    Test.startTest();
    System.assert( Database.insert( lContract, false ).isSuccess() );
    lContract.Fluxo01_Aprovado__c = true;
    System.assert( Database.update( lContract, false ).isSuccess() );
    Test.stopTest();
  }

}