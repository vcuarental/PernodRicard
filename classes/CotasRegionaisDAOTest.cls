@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: CotasRegionaisDAO.
*
* NAME: CotasRegionaisDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class CotasRegionaisDAOTest {

    static testMethod void myUnitTest() {
    	//Lista para parametro dos métodos
    	List< String > lStr = new List< String >();
    	//Chamada do método da classe
      CotasRegionaisDAO.getInstance().getListCotasRegionais( lStr );
    }
}