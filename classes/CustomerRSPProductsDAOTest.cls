@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza o teste de cobertura da classe CustomerRSPProductsDAO.
*
* NAME: CustomerRSPProductsDAOTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 14/05/2012
********************************************************************************/
private class CustomerRSPProductsDAOTest
{
    static testMethod void CustomerRSPProductsDAOTest() 
    {
      //Declaração de variáveis
      Decimal idProfile = 0;
      CustomerRSPProfiles__c cProf = null;
      
      //Cria um novo Customer Profile
      cProf = new CustomerRSPProfiles__c();
      cProf.profile_id__c = 123456;
      cProf.RecordTypeId = RecordTypeForTest.getRecType( 'CustomerRSPProfiles__c', 'BRA_Standard' );
      insert cProf;
      
      //Invoca o método getListCustomerRSPProducts
      List<CustomerRSPProducts__c> listCustomProd = CustomerRSPProductsDAO.getInstance().getListCustomerRSPProducts(cProf.profile_id__c);
    }
}