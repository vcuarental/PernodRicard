//@istest(seeAllDAta=true)
/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/
@istest
public with sharing class WS02_CustomerHandlerInterface_AR_TEST {

    @istest
    static  void CustomerHandlerInterfaceTest_AR2() 
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
      UDC__c paymentInstrument              = null;

      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','ACC_3_OnTrade_ARG');
            
      
      //Recupera o ID do perfil desejado.
      perfil = [Select Id From Profile Where Name=:'Administrador do sistema' OR Name=:'Administrador de sistema' OR Name=:'System Administrator' LIMIT 1];
      
      //Cria novo usuario.
      usuario = new User();
      usuario.FirstName       = 'Nome2';
      usuario.LastName      = 'Sobrenome2';
      usuario.Alias       = 'NSobre2';
      usuario.Email         = 'nome2@sobrenome.com';
      usuario.Username      = 'CustomerHandlerInterface@mail.com';
      usuario.CommunityNickname   = '123jjjuuu2';
      usuario.EmailEncodingKey  = 'ISO-8859-1';
      usuario.TimeZoneSidKey    = 'GMT';
      usuario.LocaleSidKey    = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c   = '234';
      usuario.ProfileId       = perfil.Id;
      usuario.Country = 'BR';
      insert usuario;
      
      system.runas(usuario){
    
          //Cria nova UDC.
          regional = new UDC__c();
          regional.CodDefUsuario__c = '4546';
          regional.CodProd__c     = '01';
          regional.CodUs__c     = '01';
          regional.Internal_Id__c   = '-01-01';
          regional.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'Standard_AR' );
          insert regional;
          
          //delete [SELECT id FROM UDC__c WHERE Internal_Id__c LIKE '%01-06%'];
          //Cria nova UDC.
          bandeira = new UDC__c();
          bandeira.CodDefUsuario__c = '179';
          bandeira.CodProd__c     = '01';
          bandeira.CodUs__c     = '06';
          bandeira.Internal_Id__c   = '01-06';
          bandeira.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'Standard_AR' );
          insert bandeira;
    
          //Nova UDC
          paymentInstrument = new UDC__c();
          paymentInstrument.Name = 'Blanco';
          paymentInstrument.CodDefUsuario__c = '179';
          paymentInstrument.CodProd__c     = '00';
          paymentInstrument.CodUs__c     = 'PY';
          paymentInstrument.Internal_Id__c   = '00-PY';

          //paymentInstrument.LAT_MX_FilterKey__c='PY-00-AR';
          paymentInstrument.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'Standard_AR' );
          insert paymentInstrument;

          //Cria novo Account.
          acc = new Account();
          acc.OwnerId = usuario.Id;
          acc.Name = 'TESTE';
          acc.CNPJ__c = '20354266645';
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
          acc.Client_code_AN8__c = '557799';
          acc.Price_Group__c = '1';
          acc.Revenue_UF__c = 'SP';
          acc.State_registration__c = '110.042.490.114';
          insert acc;
          
          System.Test.startTest();
          
          //acc.State_registration__c = '110.042.490.114';
          //update acc;
          
          //Cria novo Account.
          acc2 = new Account();
          acc2.OwnerId = usuario.Id;
          acc2.Name = 'TESTE';
          acc2.CNPJ__c = '20354266645';
          acc2.Type = 'Outros';
          acc2.RecordTypeId = idAccount;
          acc2.Status__c = 'Cliente cadastrado no JDE';
          acc2.Agency__c = '000';
          acc2.Checking_account__c = '000';
          acc2.Current_account__c = '0';
          acc2.Corporate_Name__c = 'Teste';
          acc2.Channel__c = 'Off Trade';
          acc2.Regional__c = regional.Id;
          acc2.Frequency_of_Visits__c = 'Semanal';
          acc2.Channel_Type__c = 'Direto';
          acc2.Client_code_AN8__c = '558799';
          acc2.Price_Group__c = '1';
          acc2.SaveDuplicatedFiscalID_AR__c = true;
          insert acc2;

          acc2.ParentId = acc.Id;
          //update acc2;
          
          String lIdAcc = acc2.Id;
               
          WS02_CustomerHandlerInterface_AR.CustomerInterfaceJDE(lIdAcc);
          WS02_CustomerHandlerInterface_AR.decodePhone('1-818-762-9145');
          CustomerHandlerTypes.CustomerHandlerResponseType param = new CustomerHandlerTypes.CustomerHandlerResponseType();
          param.customerInvoiceCode = 123;
          param.customerBillingCode = 123;
          param.customerShippingCode = 123;
          WS02_CustomerHandlerInterface_AR.decodeResponse(param, acc2);
          System.Test.stopTest();
      }
    }

}