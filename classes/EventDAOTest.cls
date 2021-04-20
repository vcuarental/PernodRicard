@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA TESTE DE COBERTURA NO SEGUINTE CÓDIGO: EventDAO.cls
* NAME: EventDAOTest.cls
* AUTHOR: CARLOS CARVALHO                            DATE: 20/02/2013
*
********************************************************************************/
private class EventDAOTest {

    static testMethod void myUnitTest() {
      //Lista para parametro do método
      List< String > lStr = new List< String >();
      //Chamado do método da classe
      EventDAO.getInstance().getListEventByIdVisita( lStr );
    }
}