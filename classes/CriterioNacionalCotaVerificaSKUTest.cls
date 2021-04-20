/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe de teste que verifica se já existe um critério nacional de cota para o SKU
* NAME: CriterioNacionalCotaVerificaSKUTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 02/07/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
*******************************************************************************/
@isTest
private class CriterioNacionalCotaVerificaSKUTest {

    static testMethod void myUnitTest() 
    {
      SKU__c lProd = new SKU__c();
      lProd.Name = '6111';
      lProd.Nome_do_produto__c = 'Produto de Teste';
      lProd.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c', 'BRA_Standard' );
      insert lProd; 
      
      Criterio_nacional_de_cota__c lCrit = new Criterio_nacional_de_cota__c();
      lCrit.SKU__c = lProd.id;
      lCrit.Bandeira__c = true;
      lCrit.Cota__c = 1000;
      lCrit.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c', 'BRA_Standard' );
      insert lCrit;
      
      lCrit = new Criterio_nacional_de_cota__c();
      lCrit.SKU__c = lProd.id;
      lCrit.Bandeira__c = true;
      lCrit.Cota__c = 1000;
      lCrit.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c', 'BRA_Standard' );
      try
      {
        insert lCrit;
      }
      catch( Exception e ) {}
    }
}