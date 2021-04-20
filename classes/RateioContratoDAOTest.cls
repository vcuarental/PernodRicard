@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: RateioContratoDAO.
*
* NAME: RateioContratoDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class RateioContratoDAOTest {

    static testMethod void myUnitTest() {

      //strng para parametro do método
      String str = '';
      //Chamada do método da classe
      RateioContratoDAO.getInstance().getListRateioByContractId( str );      
    }
}