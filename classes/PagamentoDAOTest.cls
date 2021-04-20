@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: PagamentoDAO.
*
* NAME: PagamentoDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class PagamentoDAOTest {

    static testMethod void myUnitTest() {
      //String para parametro
      String str = '';
      //Chamada do método da classe
      PagamentoDAO.getInstance().getPagamentoById( str );
      
    }
}