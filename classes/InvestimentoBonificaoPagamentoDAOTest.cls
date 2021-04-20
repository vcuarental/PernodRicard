@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* REALIZA TESTE DE COBERTURA DO SEGUINTE CÓDIGO:  InvestimentoBonificaoPagamentoDAO.
* NAME: InvestimentoBonificaoPagamentoDAOTest.cls
* AUTHOR: CARLOS CARVALHO                          DATE: 20/02/2013
*******************************************************************************/
private class InvestimentoBonificaoPagamentoDAOTest {

    static testMethod void myUnitTest() {
    	//String para parametro do método 
      String str = '';
      //Lista para parametro do método
      List< String > lStr = new List< String >();
      //Chamada dos métodos da classe
      InvestimentoBonificaoPagamentoDAO.getInstance().getIBPById( str );
      InvestimentoBonificaoPagamentoDAO.getInstance().getListInvestBonifPagByIdsIBP( lStr );
      
    }
}