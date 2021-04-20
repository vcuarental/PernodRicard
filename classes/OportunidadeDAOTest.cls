@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: OportunidadeDAO.
*
* NAME: OportunidadeDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/01/2017
*
********************************************************************************/
private class OportunidadeDAOTest {

    static testMethod void myUnitTest() {

      //Lista para parametro dos métodos
      List< String > lStr = new List< String >();
      //Chamada do método da classe
      OportunidadeDAO.getInstance().getListOpportunity( lStr );
      
    }

    static testMethod void myUnitTestB() {
        Utils.setMigrationDoneTest(true);   

        //Lista para parametro dos métodos
      	List< String > lStr = new List< String >();
      	//Chamada do método da classe
      	OportunidadeDAO.getInstance().LAT_getListOpportunity( lStr );
      
    }
}