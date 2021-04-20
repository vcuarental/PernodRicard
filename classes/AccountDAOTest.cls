@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA TESTE DE COBERTURA NO SEGUINTE CÓDIGO: AccountDAO.cls
* NAME: AccountDAOTest.cls
* AUTHOR: CARLOS CARVALHO                            DATE: 19/02/2013
*
********************************************************************************/
private class AccountDAOTest {

    static testMethod void myUnitTest() {
        
        List< String > lStr = new List< String >();
        AccountDAO.getInstance().getListAccountByIdsOwners( lStr );
    }
}