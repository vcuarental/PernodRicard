@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: VisitasDAO.
*
* NAME: VisitasDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class VisitasDAOTest {

    static testMethod void myUnitTest() {
    	//Lista para parametro do método
      List< String > lStr = new List< String >();
      //Chamada do método da classe
      VisitasDAO.getInstance().getListVisitasByPlanejamento( lStr );
    }
}