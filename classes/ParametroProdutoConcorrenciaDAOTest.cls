@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* REALIZA TESTE DE COBERTURA DO SEGUINTE CÓDIGO:  ParametroProdutoConcorrenciaDAO.
* NAME: ParametroProdutoConcorrenciaDAOTest.cls
* AUTHOR: CARLOS CARVALHO                          DATE: 20/02/2013
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/

private class ParametroProdutoConcorrenciaDAOTest {

    static testMethod void myUnitTest() {
        Utils.setMigrationDoneTest(false);
     	ParametroProdutoConcorrenciaDAO.getInstance().getListParametros();
    }
    static testMethod void myUnitTestB() {
        Utils.setMigrationDoneTest(true);
      	ParametroProdutoConcorrenciaDAO.getInstance().getListParametros();
    }
}