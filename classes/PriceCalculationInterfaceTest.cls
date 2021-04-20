@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe PriceCalculationInterface.cls
* NAME: PriceCalculationInterfaceTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 31/05/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
 /********************************************************************************
*
* MIGRACION LICENCIAS
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/

public class PriceCalculationInterfaceTest {

      public static boolean shouldhaveError;
      public static boolean shouldhaveException;

      @istest
      static void PriceCalculationInterfaceTest()
      {
            //Declaração de variáveis.
            Utils.setMigrationDoneTest(false);
            Account acc                           = null;
            UDC__c regional, bandeira, cidade     = null;
            Profile perfil                        = null;
            Opportunity opp                       = null;
            OpportunityLineItem oli               = null;
            User usuario                          = null;
            Product2 produto                      = null;
            PricebookEntry pbe                    = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');

            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');



            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;

            insert bandeira;

            //Recupera o ID do perfil desejado.
             usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
            insert usuario;

            //Cria novo Account.
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
            insert acc;

            test.startTest();
            Utils.setMigrationDoneTest(false);
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            produto = new Product2();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.IsActive = true;
            produto.CD_Unit__c = 'UN';
            produto.Internal_id__c = '146';
            //produto.QT_lead_time__c = 5;
            produto.SKU__c = '444';
            produto.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
            insert produto;

            //Recupera o catalogo de preço padrão
            List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE isStandard=true limit 1];

            //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            insert entradaCatalogoPreco;

            //Recupera os IDS de tipo de registro.
            idOpportunity = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade');

            //Cria nova oportunidade.
            opp = new Opportunity();
            opp.Name = 'Opp TESTE COTA';
            opp.closeDate = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.AccountId = acc.Id;
            opp.StageName = 'Novo Pedido';

            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new OpportunityLineItem();
            oli.PricebookEntryId = entradaCatalogoPreco.Id;
            oli.OpportunityId    = opp.Id;
            oli.UnitPrice        = 12;
            oli.Quantity         = 12;
            insert oli;


            String lIdOpp = opp.Id;

            PriceCalculationInterface.PriceCalculation(lIdOpp, null, null);
            delete opp;

            PriceCalculationInterface.PriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.getConnectionParameter();

            test.stopTest();
      }

      @istest
      static void getMockResponse(){
            LAT_BR_PriceCalculation.priceCatalogueHeaderOutput res = PriceCalculationInterface.getMockResponse();
            PriceCalculationInterface.getBaseDiscount(res.priceCatalogueDetails[0]);

      }

      @istest
      static void PriceCalculationInterfaceTest2() {
            //Declaração de variáveis.
            Utils.setMigrationDoneTest(true);
            Account acc                           = null;
            UDC__c regional, bandeira, cidade     = null;
            Profile perfil                        = null;
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');

            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');



            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;

            insert bandeira;

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
            insert usuario;

            //Cria novo Account.
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
            insert acc;

            test.startTest();
            Utils.setMigrationDoneTest(true);
            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '1-146';
            //produto.QT_lead_time__c = 5;
            produto.LAT_Sku__c = '444';
            produto.LAT_IsRefactorProduct__c = 'Y';
            produto.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
            insert produto;

            //Recupera os IDS de tipo de registro.
            idOpportunity = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade');

            //Cria nova oportunidade.
            opp = new LAT_Opportunity__c();
            opp.Name = 'Opp TESTE COTA';
            opp.LAT_CloseDate__c = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.LAT_Account__c = acc.Id;
            opp.LAT_StageName__c = 'Novo Pedido';

            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            insert oli;


            String lIdOpp = opp.Id;
            shouldhaveException = false;
            opp.LAT_Country__c = 6;
            opp.LAT_IsAdmin__C = true;
            update opp;
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.shouldhaveException = false;
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);
            delete opp;
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.shouldhaveException = true;
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.getConnectionParameter();
            test.stopTest();
      }

      @istest
      static void PriceCalculationInterfaceTest2OldPC() {
            //Declaração de variáveis.
            Utils.setMigrationDoneTest(true);
            Account acc                           = null;
            UDC__c regional, bandeira, cidade     = null;
            Profile perfil                        = null;
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
            CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Brasil');
            cred.Exec_new_Price_Calc__c = false;
            update cred;

            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');



            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;

            insert bandeira;

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
            insert usuario;

            //Cria novo Account.
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
            insert acc;

            test.startTest();
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            Utils.setMigrationDoneTest(true);
            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '1-146';
            //produto.QT_lead_time__c = 5;
            produto.LAT_Sku__c = '444';
            produto.LAT_IsRefactorProduct__c = 'Y';
            produto.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
            insert produto;

            //Recupera os IDS de tipo de registro.
            idOpportunity = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade');

            //Cria nova oportunidade.
            opp = new LAT_Opportunity__c();
            opp.Name = 'Opp TESTE COTA';
            opp.LAT_CloseDate__c = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.LAT_Account__c = acc.Id;
            opp.LAT_StageName__c = 'Novo Pedido';

            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            insert oli;


            String lIdOpp = opp.Id;
            shouldhaveException = false;
            opp.LAT_Country__c = 6;
            opp.LAT_IsAdmin__C = true;
            update opp;
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.shouldhaveException = false;
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);
            delete opp;
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.shouldhaveException = true;
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);
            PriceCalculationInterface.getConnectionParameter();
            test.stopTest();
      }

      @istest
      static void PriceCalculationInterfaceTestWithException()
      {
            //Declaração de variáveis.
            Utils.setMigrationDoneTest(true);
            Account acc                           = null;
            UDC__c regional, bandeira, cidade     = null;
            Profile perfil                        = null;
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');

            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');



            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;

            insert bandeira;

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
            insert usuario;

            //Cria novo Account.
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
            insert acc;

            test.startTest();
            Utils.setMigrationDoneTest(true);
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '1-146';
            //produto.QT_lead_time__c = 5;
            produto.LAT_Sku__c = '444';
            produto.LAT_IsRefactorProduct__c = 'Y';
            produto.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
            insert produto;

            //Recupera os IDS de tipo de registro.
            idOpportunity = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade');

            //Cria nova oportunidade.
            opp = new LAT_Opportunity__c();
            opp.Name = 'Opp TESTE COTA';
            opp.LAT_CloseDate__c = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.LAT_Account__c = acc.Id;
            opp.LAT_StageName__c = 'Novo Pedido';

            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            insert oli;
            List<LAT_OpportunityLineItem__c> olis = new List<LAT_OpportunityLineItem__c>{oli};


            String lIdOpp = opp.Id;
            shouldhaveException = true;
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);    
            PriceCalculationInterface.debug = new LAT_DebugUtil();        
            PriceCalculationInterface.logAsRegistry = new LAT_Log__c();
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, olis, null);
            PriceCalculationInterface.debug = new LAT_DebugUtil();        
            PriceCalculationInterface.logAsRegistry = new LAT_Log__c();
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);
            delete opp;
            PriceCalculationInterface.debug = new LAT_DebugUtil();        
            PriceCalculationInterface.logAsRegistry = new LAT_Log__c();
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);

            PriceCalculationInterface.getConnectionParameter();

            test.stopTest();
      }
      @istest
      static void PriceCalculationInterfaceTestWithException2()
      {
            //Declaração de variáveis.
            Utils.setMigrationDoneTest(true);
            Account acc                           = null;
            UDC__c regional, bandeira, cidade     = null;
            Profile perfil                        = null;
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');

            //Recupera os IDS de tipo de registro.
            idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');



            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c     = '01';
            regional.CodUs__c     = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c     = '01';
            bandeira.CodUs__c     = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;

            insert bandeira;

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
            insert usuario;

            //Cria novo Account.
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
            insert acc;

            test.startTest();
            Utils.setMigrationDoneTest(true);
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '1-146';
            //produto.QT_lead_time__c = 5;
            produto.LAT_Sku__c = '444';
            produto.LAT_IsRefactorProduct__c = 'Y';
            produto.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
            insert produto;

            //Recupera os IDS de tipo de registro.
            idOpportunity = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade');

            //Cria nova oportunidade.
            opp = new LAT_Opportunity__c();
            opp.Name = 'Opp TESTE COTA';
            opp.LAT_CloseDate__c = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.LAT_Account__c = acc.Id;
            opp.LAT_StageName__c = 'Novo Pedido';

            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            insert oli;
            List<LAT_OpportunityLineItem__c> olis = new List<LAT_OpportunityLineItem__c>{oli};


            String lIdOpp = opp.Id;
            PriceCalculationInterface.shouldhaveException = true;
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, null, null);    
            PriceCalculationInterface.debug = new LAT_DebugUtil();        
            PriceCalculationInterface.logAsRegistry = new LAT_Log__c();
            PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, olis, null);
            PriceCalculationInterface.debug = new LAT_DebugUtil();        
            PriceCalculationInterface.logAsRegistry = new LAT_Log__c();
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);
            delete opp;
            PriceCalculationInterface.debug = new LAT_DebugUtil();        
            PriceCalculationInterface.logAsRegistry = new LAT_Log__c();
            PriceCalculationInterface.LAT_PriceCalculation(lIdOpp, null, null);

            PriceCalculationInterface.getConnectionParameter();

            test.stopTest();
      }

    @istest
    static void PriceCalculationInterfaceTestB(){

      PriceCalculationTypes.PriceCalculationFaultType l1 = new PriceCalculationTypes.PriceCalculationFaultType();
      l1.faultCode = '0';
      l1.faultMessage = '';

      PriceCalculationTypes.PriceCalculationHeaderResponseType l2 = new PriceCalculationTypes.PriceCalculationHeaderResponseType();
      l2.customerCode = 0;

      PriceCalculationTypes.PriceCalculationHeaderRequestType l3 = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
      l3.businessUnit = '';
      l3.customerCode = 0;
      l3.freightType = '';
      l3.promisedDate = system.today();
      l3.salesman = '0';

      test.startTest();

      PriceCalculationTypes.PriceCalculationItemResponseType l4 = new PriceCalculationTypes.PriceCalculationItemResponseType();
      l4.priceComponents = '';
      l4.salesPriceValue = 0;
      l4.sku = '0';

      PriceCalculationTypes.PriceCalculationItemRequestType l5 = new PriceCalculationTypes.PriceCalculationItemRequestType();
      l5.billedTotalQuantity = 0;
      l5.bonusPercentual = 0;
      l5.bonusQuantity = 0;
      l5.bonusUnit = '';
      l5.paymentTerm = '';
      l5.percentualDiscount = 0;
      l5.salesUOM = '';
      l5.sku = '0';

      test.stopTest();

    }
}