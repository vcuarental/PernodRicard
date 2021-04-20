@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA TESTE DE COBERTURA NO SEGUINTE CÓDIGO: ContratoSemaphoro.cls
* NAME: ContratoSemaphoroTest.cls
* AUTHOR: CARLOS CARVALHO                            DATE: 20/02/2013
*
********************************************************************************/
private class ContratoSemaphoroTest {

    static testMethod void myUnitTest() {
        //Retorna FALSO
      System.assert( !ContratoSemaphoro.setNewCode('1', 'Teste') );
      //Retorna FALSO
      System.assert( !ContratoSemaphoro.setNewCode('1', 'Teste2') );
      //Retorna TRUE, por ja estar em execução
      System.assert( ContratoSemaphoro.setNewCode('1', 'Teste2') );
    }
}