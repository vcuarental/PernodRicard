@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: PagamentoVerbaDAO.
*
* NAME: PagamentoVerbaDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class PagamentoVerbaDAOTest {

    static testMethod void myUnitTest() {
      //String para parametro do método
      String str = '';
      //Chamada do método da classe
      PagamentoVerbaDAO.getInstance().getListPagVerbaByIdPgto( str );
    }
}