@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza tese de cobertura do seguinte código: ContractDAO.cls
*
* NAME: ContractDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class ContractDAOTest {

    static testMethod void myUnitTest() {
    	//string de parametro
    	String str = '';
    	//Lista de parametro
    	List< String > lStr = new List< String >();
    	//Chamada dos métodos da classe
      ContractDAO.getInstance().getContractById( str );
      ContractDAO.getInstance().getListContractByAccount( lStr );
      ContractDAO.getInstance().getListContractByIds( lStr );
    }
}