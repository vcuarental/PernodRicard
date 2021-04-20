/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do controlador OpportunityProductRedirectExtension.cls
* NAME: OpportunityProductRedirectExtensionTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 05/06/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 11/01/2013 
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/
@isTest(seeAllData=true)
private class OpportunityProductRedirectExtensionTest {

    static testMethod void OpportunityProductRedirectExtensionTest() 
    {
      Utils.setMigrationDoneTest(false);      
     //Declaração de variáveis
     Account acc                                   = null;
     UDC__c regional, bandeira, cidade, deposito   = null;
     Profile perfil                       = null;
     Opportunity opp                      = null;
     OpportunityLineItem oli,oli3         = null;
     Product2 produto                     = null;
     Pricebook2 pricebook, standardPB     = null;
     PricebookEntry pbe, pbe2             = null;
     List<RecordType> listRecType         = null;
     List<String> developerName           = null;
     Map<String, String> mapRecType       = null;
     String idAccount                     = null;
     String idOpportunity                 = null; 
     Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
     
      //Recupera os IDS de tipo de registro
      idAccount = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      
      
        
      
      //Cria nova UDC
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '1234';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      
      //Cria nova UDC
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '1236';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      
      
      //Cria nova UDC
      deposito = new UDC__c();
      deposito.CodDefUsuario__c = '05';
      deposito.CodProd__c     = 'CRM';
      deposito.CodUs__c     = 'DF';
      deposito.Internal_Id__c   = '876';
      deposito.RecordTypeId = idRecTypeUDC;
      insert deposito;

      //Recupera o ID do perfil desejado
      User usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
      
      //Cria novo Account
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      //acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      //acc.Customer_Flag__c = bandeira.Id;
      acc.Carriers_Numbers__c = '123';
      //acc.Business_Unit__c = deposito.Id;
      
      insert acc;
      
      //Recupera um produto no ambiente.
      //produto = new Product2();//[Select Id, Name, Sku__c From Product2 Where Sku__c = '6343' limit 1];
      produto = new Product2();
      produto.Name = 'Cloud2b';
      produto.IsActive = true;
      produto.CD_Unit__c = 'UN';
      produto.Internal_id__c = '444';
      //produto.QT_lead_time__c = 5;
      produto.SKU__c = '5666';
      produto.RecordTypeId = RecordTypeForTest.getRecType('Product2', 'BRA_Standard');
      insert produto;
      
      standardPB = [Select Id From Pricebook2 Where isStandard = true];
      
      pbe2 = new PricebookEntry();
      pbe2.Product2Id = produto.Id;
      pbe2.UnitPrice = 12;
      pbe2.Pricebook2Id = standardPB.Id;
      pbe2.IsActive =true;
      pbe2.UseStandardPrice = false;
      
      insert pbe2;
      
      //Recupera os IDS de tipo de registro
      idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
      
      //Cria novo pricebook
      pricebook = new Pricebook2();
      pricebook.Name = '1';
      pricebook.Description = '1';
      
      insert pricebook;
      
      //Cria novo pricebookEntry
      pbe = new PricebookEntry();
      pbe.Product2Id = produto.Id;
      pbe.UnitPrice = 12;
      pbe.Pricebook2Id = pricebook.Id;
      pbe.IsActive =true;
      pbe.UseStandardPrice = false;
      
      insert pbe;
      
      //Cria nova oportunidade
      opp = new Opportunity();
      opp.Name = 'Opp TESTE COTA';
      opp.closeDate = System.today()+1;
      opp.RecordTypeId = idOpportunity;
      opp.AccountId = acc.Id;
      opp.StageName = 'Novo Pedido';
      
      insert opp;
       
      oli = new OpportunityLineItem();
      oli.PricebookEntryId = pbe.Id;
      oli.OpportunityId =opp.Id;
      oli.UnitPrice = 12;
      oli.Quantity = 12;
      
      insert oli;
      
      
      //Armazena a visita criada em uma lista.
      List<OpportunityLineItem> listOli = [Select Id From OpportunityLineItem Where Id =: oli.Id];
      
      //Excuta o standard controller
      ApexPages.StandardController sc = new ApexPages.StandardController(listOli[0]);
      
      //Executa o controller customizado e seus métodos
      opportunityProductRedirectExtension con = new opportunityProductRedirectExtension(sc);
      con.redirect();
    }

        static testMethod void OpportunityProductRedirectExtensionTestb() 
    {
      Utils.setMigrationDoneTest(false);      
     //Declaração de variáveis
     Account acc                                   = null;
     UDC__c regional, bandeira, cidade, deposito   = null;
     Profile perfil                       = null;
     Opportunity opp                      = null;
     OpportunityLineItem oli,oli3         = null;
     Product2 produto                     = null;
     Pricebook2 pricebook, standardPB     = null;
     PricebookEntry pbe, pbe2             = null;
     List<RecordType> listRecType         = null;
     List<String> developerName           = null;
     Map<String, String> mapRecType       = null;
     String idAccount                     = null;
     String idOpportunity                 = null; 
     Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
     
      //Recupera os IDS de tipo de registro
      idAccount = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      
      
      
      //Cria nova UDC
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '1234';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      
      //Cria nova UDC
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '1236';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      
      
      //Cria nova UDC
      deposito = new UDC__c();
      deposito.CodDefUsuario__c = '05';
      deposito.CodProd__c     = 'CRM';
      deposito.CodUs__c     = 'DF';
      deposito.Internal_Id__c   = '876';
      deposito.RecordTypeId = idRecTypeUDC;
      insert deposito;

      //Recupera o ID do perfil desejado
      User usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
        
      
      //Cria novo Account
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      //acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      //acc.Customer_Flag__c = bandeira.Id;
      acc.Carriers_Numbers__c = '123';
      //acc.Business_Unit__c = deposito.Id;
      
      insert acc;
      
      //Recupera um produto no ambiente.
      //produto = new Product2();//[Select Id, Name, Sku__c From Product2 Where Sku__c = '6343' limit 1];
      produto = new Product2();
      produto.Name = 'Cloud2b';
      produto.IsActive = true;
      produto.CD_Unit__c = 'UN';
      produto.Internal_id__c = '444';
      //produto.QT_lead_time__c = 5;
      produto.SKU__c = '5666';
      produto.RecordTypeId = RecordTypeForTest.getRecType('Product2', 'BRA_Standard');
      insert produto;

            //Cria novo pricebook
      pricebook = new Pricebook2();
      pricebook.Name = '1';
      pricebook.Description = '1';
      standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 
      insert pricebook;
      
      pbe2 = new PricebookEntry();
      pbe2.Product2Id = produto.Id;
      pbe2.UnitPrice = 12;
      pbe2.Pricebook2Id = standardPB.Id;
      pbe2.IsActive =true;
      pbe2.UseStandardPrice = false;
      
      insert pbe2;
      
      //Recupera os IDS de tipo de registro
      idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
      

      
      //Cria novo pricebookEntry
      pbe = new PricebookEntry();
      pbe.Product2Id = produto.Id;
      pbe.UnitPrice = 12;
      pbe.Pricebook2Id = pricebook.Id;
      pbe.IsActive =true;
      pbe.UseStandardPrice = false;
      
      insert pbe;
      
      //Cria nova oportunidade
      opp = new Opportunity();
      opp.Name = 'Opp TESTE COTA';
      opp.closeDate = System.today()+1;
      opp.RecordTypeId = idOpportunity;
      opp.AccountId = acc.Id;
      opp.StageName = 'Novo Pedido';
      
      insert opp;
       
      oli = new OpportunityLineItem();
      oli.PricebookEntryId = pbe.Id;
      oli.OpportunityId =opp.Id;
      oli.UnitPrice = 12;
      oli.Quantity = 12;
      
      insert oli;
      
      
      //Armazena a visita criada em uma lista.
      List<OpportunityLineItem> listOli = [Select Id From OpportunityLineItem Where Id =: oli.Id];
      
      //Excuta o standard controller
      ApexPages.StandardController sc = new ApexPages.StandardController(listOli[0]);
      
      //Executa o controller customizado e seus métodos
      opportunityProductRedirectExtension con = new opportunityProductRedirectExtension(sc);
      con.redirect();
    }

    static testMethod void OpportunityProductRedirectExtensionTest2() 
    {
      Utils.setMigrationDoneTest(true);      
     //Declaração de variáveis
     Account acc                                   = null;
     UDC__c regional, bandeira, cidade, deposito   = null;
     Profile perfil                       = null;
     LAT_Opportunity__c opp                      = null;
     LAT_OpportunityLineItem__c oli,oli3         = null;
     LAT_Product__c produto                     = null;
     List<RecordType> listRecType         = null;
     List<String> developerName           = null;
     Map<String, String> mapRecType       = null;
     String idAccount                     = null;
     String idOpportunity                 = null; 
     Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
     
      //Recupera os IDS de tipo de registro
      idAccount = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      
      
      
      //Cria nova UDC
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '1234';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      
      //Cria nova UDC
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '1236';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      
      
      //Cria nova UDC
      deposito = new UDC__c();
      deposito.CodDefUsuario__c = '05';
      deposito.CodProd__c     = 'CRM';
      deposito.CodUs__c     = 'DF';
      deposito.Internal_Id__c   = '876';
      deposito.RecordTypeId = idRecTypeUDC;
      insert deposito;
      
      //Recupera o ID do perfil desejado
      User usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
        

      //Cria novo Account
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      //acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      //acc.Customer_Flag__c = bandeira.Id;
      acc.Carriers_Numbers__c = '123';
      //acc.Business_Unit__c = deposito.Id;
      
      insert acc;
      
      //Recupera um produto no ambiente.
      //produto = new Product2();//[Select Id, Name, Sku__c From Product2 Where Sku__c = '6343' limit 1];
      produto = new LAT_Product__c();
      produto.Name = 'Cloud2b';
      produto.LAT_IsActive__c = true;
      produto.LAT_CDUnit__c = 'UN';
      produto.LAT_ExternalId__c = '444';
      //produto.QT_lead_time__c = 5;
      produto.CurrencyIsoCode = 'BRL';
      produto.CurrencyIsoCode = 'BRL';
      produto.LAT_Sku__c = '5666';
      produto.LAT_IsRefactorProduct__c = 'Y';
      produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
      insert produto;
      
      
      //Recupera os IDS de tipo de registro
      idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','Nova_oportunidade');
      
      
      //Cria nova oportunidade
      opp = new LAT_Opportunity__c();
      opp.Name = 'Opp TESTE COTA';
      opp.LAT_CloseDate__c = System.today()+1;
      opp.RecordTypeId = idOpportunity;
      opp.LAT_Account__c = acc.Id;
      opp.LAT_StageName__c = 'Novo Pedido';
      opp.CurrencyIsoCode = 'BRL';
      
      insert opp;
       
      oli = new LAT_OpportunityLineItem__c();
      oli.LAT_Product__c = produto.Id;
      oli.LAT_Opportunity__c =opp.Id;
      oli.LAT_UnitPrice__c = 12;
      oli.LAT_Quantity__c = 12;
      
      insert oli;
      
      
      //Armazena a visita criada em uma lista.
      List<LAT_OpportunityLineItem__c> listOli = [Select Id From LAT_OpportunityLineItem__c Where Id =: oli.Id];
      //List<LAT_OpportunityLineItem__c> listOli2 = new List<LAT_OpportunityLineItem__c> {oli};
      //Excuta o standard controller
      ApexPages.StandardController sc = new ApexPages.StandardController(oli);
      
      //Executa o controller customizado e seus métodos
      LAT_opportunityProductRedirectExtension con = new LAT_opportunityProductRedirectExtension(sc);
      con.redirect();
    }
}