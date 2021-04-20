@isTest(seeAllData=true)
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Realiza teste de cobertura de código: UDCLoad.cls
*
* NAME: UDCLoadTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
private class UDCLoadTest {

    static testMethod void UDCLoadTest() {
      
      Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
      
      //Declaração de variáveis.
      UDC__c udc,udc2,udc3 = null;
      List<String> lUdc = new List<String>();
      
      //Cria nova udc
      udc = new UDC__c();
      udc.CodDefUsuario__c = '1400';
      udc.CodProd__c = '12';
      udc.CodUs__c = '33';
      udc.Internal_Id__c = '1400'+'12'+'33';
      udc.RecordTypeId = idRecTypeUdc;
      insert udc;
      
      
      lUdc = UDCLoad.ETL_UDCLoad(1, '13', '20', '2', 'testte', '4444');
      lUdc = UDCLoad.ETL_UDCLoad(1, '12', '33', '50', 'teste', '1400');
      
    }
}