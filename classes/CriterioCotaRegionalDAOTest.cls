@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: CriterioCotaRegionalDAO.
*
* NAME: CriterioCotaRegionalDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class CriterioCotaRegionalDAOTest {

    static testMethod void myUnitTest() {
      //Lista para parametro do método
      List< String > lStr = new List< String >();
      //Chamada do método da classe
      CriterioCotaRegionalDAO.getInstance().getListCriterioByIdSKU( lStr );
    }
}