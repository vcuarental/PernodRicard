@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: TarefaDAO.
*
* NAME: TarefaDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class TarefaDAOTest {

    static testMethod void myUnitTest() {
      List< String > lStr = new List< String >();
      String str = ''; 
      TarefaDAO.getInstance().getTaskByRecordTypeAndOwner( str , lStr );
    }
}