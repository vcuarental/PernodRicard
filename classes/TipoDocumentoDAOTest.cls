@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: TipoDocumentoDAO.
*
* NAME: TipoDocumentoDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 20/02/2013
********************************************************************************/
private class TipoDocumentoDAOTest {

    static testMethod void myUnitTest() {
      
      //strng para parametro do método
      String str = '';
      //Chamada do método da classe
      TipoDocumentoDAO.getInstance().getListTipoDocumento( str );
      
    }
}