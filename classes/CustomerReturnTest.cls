@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe CustomerReturn.cls
* NAME: CustomerReturnTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 31/05/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013 
*
* MAINTENANCE: CORRIGIDO TIPO DE REGISTRO PARA UDC__c.
* AUTHOR: CARLOS CARVALHO                           DATE: 28/01/2013 
********************************************************************************/
private class CustomerReturnTest 
{

    static testMethod void CustomerReturnTest() 
    {
      //Declaração de variáveis.
      Account acc,acc2                      = null;
      UDC__c regional, bandeira, cidade     = null;
      Profile perfil                        = null;
      User usuario                          = null;
      List<RecordType> listRecType          = null;
      List<String> developerName            = null;
      Map<String, String> mapRecType        = null;
      String idAccount                      = null;
      
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
      
      //Recupera o ID do perfil desejado.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        
      try{insert usuario;}catch(Exception e){}
      
      List<UDC__c> listUDC = new List<UDC__c>();
    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
      insert regional;
    
      //Cria novo Account.
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'TESTE';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Channel_Type__c = 'Direto';
      acc.Client_code_AN8__c = '557797';
      acc.Price_Group__c = '1';
     insert acc;
      
      
      CustomerReturn.ETL_SF_ClientLoad(12, '557797', '1', '', '234', '1', '3');
      
     
 
    }
}