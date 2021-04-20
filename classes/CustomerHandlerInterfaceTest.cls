/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe CustomerHandlerInterface.cls
* NAME: CustomerHandlerInterfaceTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 31/05/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
********************************************************************************/
@isTest
private class CustomerHandlerInterfaceTest 
{ 
      @testSetup
      public static void testSetup(){
            LAT_WS_CustomerHandlerInterface_Test.testSetup();
      }     

      @isTest 
      static void customerHandlerInterfaceTest1 () {
            //Declaração de variáveis.
            Account acc, acc2                  = null;
            UDC__c regional, bandeira, cidade  = null;
            Profile perfil                     = null;
            User usuario                       = null;
            List <RecordType> listRecType      = null;
            List <String> developerName        = null;
            Map <String, String> mapRecType    = null;
            String idAccount                   = null;
            
            //Load RecordTypes
            idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
            
            //Load Profile
            usuario = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' LIMIT 1];
            //Creates UDC
            regional                  = new UDC__c();//
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c       = '01';
            regional.CodUs__c         = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            
            //Creates UDC
            bandeira                  = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c       = '01';
            bandeira.CodUs__c         = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');

            insert new List<UDC__c>{bandeira, regional};
            //Create Account to Update
            Test.startTest();
            Account braOnTrade               = LAT_WS_CustomerHandlerInterface_Test.createAccountFromScratch();
            braOnTrade.OwnerId               = usuario.Id;

            //Account a = [SELECT Id FROM Account WHERE RecordTypeId IN :]
            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            try{CustomerHandlerInterface.CustomerInterfaceJDE(braOnTrade.Id);}catch(Exception e){}
            CustomerHandlerTypes.CustomerHandlerResponseType resp = new CustomerHandlerTypes.CustomerHandlerResponseType();
            resp.customerInvoiceCode = 1234;
            resp.customerBillingCode = 1234;
            resp.customerShippingCode = 1234;
            CustomerHandlerInterface.decodeResponse(resp, braOnTrade);
            Test.stopTest();

      }

}