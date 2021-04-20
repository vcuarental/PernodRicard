@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do código: AgrupamentoFiscalYearDAO.cls
* NAME: AgrupamentoFiscalYearDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 05/10/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
private class AgrupamentoFiscalYearDAOTest {

    static testMethod void myUnitTest() {
        List< String > lList = new List< String >();
        List< String > lList2 = new List< String >();
      Agrupamento_Fiscal_Year__c agrp = AgrupamentoFiscalYearDAO.getInstance().getAgrupamentoById( null );
      List< Agrupamento_Fiscal_Year__c > listAgrup = AgrupamentoFiscalYearDAO.getInstance().getListAgrupByIdContractFiscalYear(lList, lList2);
    }
}