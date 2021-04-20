@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA O TESTE DE COBERTURA DOS SEGUINTES CÓDIGOS:
*                 ContaCopiaIdGerenteRegionalArea - 100%
*                 CriaCriterioRegional - 100%
*                 TRCustomerInterface - 80%
*                 UserDAO - 100%
* NAME: ContaCopiaIdGerenteRegionalAreaTest.CLS
* AUTHOR: CARLOS CARVALHO                           DATE: 12/03/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 14/05/2012
********************************************************************************/
private class ContaCopiaIdGerenteRegionalAreaTest {

    static testMethod void ContaCopiaIdGerenteRegionalAreaTest() 
    {
      //Declaração de variáveis.
      List<String> listDeveloperName = new List<String>();
      String idEventos = null; 
      String idRecTypeCaso = null;
      Map<String, String> mapRecType = new Map<String, String>();
      List<RecordType> listRecType = new List<RecordType>();
      Profile perfil = null;
      User usuario = null;
      User gerente = null;
      Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            
      //Recupera um Perfil no ambiente
      // gerente = new User();
      // gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
      // insert gerente;

      //Database.insert(gerente);
      //try{Database.insert(gerente);}catch(Exception e){}
        
      //Cria novo usuario.
      // usuario = new User();
      // usuario.FirstName       = 'nome2';
      // usuario.LastName      = 'Sobrenome2';
      // usuario.Alias       = 'NSobres2';
      // usuario.Email         = 'usuario@sobrenome2.com';
      // usuario.Username      = 'devtestusercloud2b2@cloud2b.com.br';
      // usuario.CommunityNickname   = '1234jjuuuU';
      // usuario.EmailEncodingKey  = 'ISO-8859-1';
      // usuario.TimeZoneSidKey    = 'GMT';
      // usuario.LocaleSidKey    = 'en_Us';
      // usuario.LanguageLocaleKey = 'en_Us';
      // usuario.C_digo_JDE__c   = '235';
      // usuario.ProfileId       = gerente.ProfileId;
      // usuario.Gerente_de_area__c  = gerente.Id;
      // usuario.Gerente_regional__c = gerente.Id;
      // usuario.Country = 'BR';
      // insert usuario;
      //Database.insert(usuario);
      //try{Database.insert(usuario);}catch(Exception e){}
      
      // // Cria uma UDC_Tabela
      // UDC__c UdcTest = new UDC__c();
      // UdcTest.CodUs__c = '03';
      // UdcTest.CodProd__c = '01';
      // UdcTest.Name = 'KA';
      // UdcTest.Internal_Id__c = '1239';
      // UdcTest.RecordTypeId = idRecTypeUdc;
      // //Database.insert(UdcTest);
      // //try{Database.insert(UdcTest);}catch(Exception e){}
         
      //Cria novo Account.
      Account acc = new Account();
      //acc.OwnerId = usuario.Id;
      acc.Name = 'Conta teste Trigger';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.Status__c = 'XXXX';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      //acc.Sub_Channel_Rating__c = UdcTest.Id;
      
      acc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'LAT_Off_Trade_Faturamento');
      acc.Revenue_UF__c = 'SP';
      insert acc;
      //Database.insert(acc);
      //try{Database.insert(acc);}catch(Exception e){}
      // test.startTest();
      

      // //Cria novo Account.
      // account acc2 = new account();
      // acc2.OwnerId = usuario.Id;
      // acc2.Name = 'Conta teste Trigger 2';
      // acc2.CNPJ__c = '64897108000101';
      // acc2.Type = 'Outros';
      // acc2.Status__c = 'XXXX';
      // acc2.Agency__c = '000';
      // acc2.Checking_account__c = '000';
      // acc2.Current_account__c = '0';
      // acc2.Corporate_Name__c = 'Teste';
      // acc2.ParentId = acc.Id;
      // acc2.Sub_Channel_Rating__c = UdcTest.Id;
      // acc2.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'Off_Trade');
      // acc2.Revenue_UF__c = 'RS';
      // //Database.insert(acc2);
      // //try{Database.insert(acc2);}catch(Exception e){}
      
      // //atualiza a conta.
      // acc.Area_Manager__c = null;
      // acc.Regional_Manager__c = null;
      // acc.Revenue_UF__c = 'SE';
      // acc.OwnerId = gerente.Id;
      // //Database.update(acc);
      // //try{Database.update(acc);}catch(Exception e){}
      // update acc;

      // acc2.Revenue_UF__c = 'DF';
      // //Database.update(acc2);
      // //try{Database.update(acc2);}catch(Exception e){}
      
      // test.stopTest();   
    }
}