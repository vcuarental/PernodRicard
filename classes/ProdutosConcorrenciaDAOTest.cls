@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do controlador ProdutosConcorrenciaDAO.cls
* NAME: ProdutosConcorrenciaDAOTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 31/05/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/
private class ProdutosConcorrenciaDAOTest 
{
    static testMethod void ProdutosConcorrenciaDAOTest() 
    {
    	Utils.setMigrationDoneTest(false); 
    	List<String> listString = new List<String>();
     	listString.add('1234');
      
 		List<Produto_Concorr_ncia__c> listProduto = new List<Produto_Concorr_ncia__c>();
      	listProduto = ProdutosConcorrenciaDAO.getInstance().getListProdutoConcorrenciaById(listString);
    }
    static testMethod void ProdutosConcorrenciaDAOTestB() 
    {
    	Utils.setMigrationDoneTest(true); 
    	List<String> listString = new List<String>();
     	listString.add('1234');
      
 		List<Produto_Concorr_ncia__c> listProduto = new List<Produto_Concorr_ncia__c>();
      	listProduto = ProdutosConcorrenciaDAO.getInstance().getListProdutoConcorrenciaById(listString);
    }
}