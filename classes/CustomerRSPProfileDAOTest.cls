@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura dos seguintes códigos: CustomerRSPProfileDAO.
*
* NAME: CustomerRSPProfileDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 14/05/2012
*
********************************************************************************/
private class CustomerRSPProfileDAOTest {

    static testMethod void CustomerRSPProfileDAOTest() 
    {
      //Invoca o método getListCustomerRSPProfiles
      List<CustomerRSPProfiles__c> listCustomProfile = CustomerRSPProfileDAO.getInstance().getListCustomerRSPProfiles();
    }
}