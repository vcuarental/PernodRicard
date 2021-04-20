@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do seguinte código: PlanejamentoDAO.cls
*
* NAME: PlanejamentoDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
private class PlanejamentoDAOTest {

    static testMethod void PlanejamentoDAOTest() 
    {
      List<String> listString = new List<String>();
      listString.add('TESTE');
      
      List<Planejamento__c> listPlanejamento = PlanejamentoDAO.getInstance().getListPlanejamento(listString);
      listPlanejamento = PlanejamentoDAO.getInstance().getListPlanejamentoEmAndamento();
    }
}