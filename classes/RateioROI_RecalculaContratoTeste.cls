@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA TESTE DE COBERTURA DO SEGUINTE CÓDIGO: RateioROI_RecalculaContrato.trigger
* NAME: RateioROI_RecalculaContratoTeste.cls
* AUTHOR: ROGÉRIO ALVARENGA                         DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
private class RateioROI_RecalculaContratoTeste {

    static testMethod void myUnitTest() 
    {
       Rateio_do_Contrato__c lRateio = new Rateio_do_Contrato__c();
       lRateio.Perc_de_Rateio__c = 100;
       lRateio.RecordTypeId = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c', 'BRA_Standard' );
       insert lRateio;
    }
}