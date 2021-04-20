/**********************************************
 Dev: Juan Pablo Cubo Version: 1
**********************************************/
 /********************************************************************************
*
* MIGRACION LICENCIAS
* AUTHOR: ZIMMIC                     DATE: 16/11/2016
*
********************************************************************************/

@istest(seeAllDAta=true)
public with sharing class WS04_PriceCalculationInterface_AR_TEST {
    
    public static LAT_PriceCalculationProcessingVersion__c createProcessingVersionXCountry(String country, String orderType) {
        LAT_PriceCalculationProcessingVersion__c csPV = new LAT_PriceCalculationProcessingVersion__c(
            Name = 'test'+country,
            Country__c = country,
            Order_Type__c = orderType,
            Processing_Version__c = 'ABC123');

        return csPV;
    }
    static testMethod void PriceCalculationInterfaceTest(){
        Utils.setMigrationDoneTest(false);
        //Declaração de variáveis.
        Account acc = null;
        UDC__c regional, bandeira, cidade = null;
        Opportunity opp = null;
        User usuario = null;
        OpportunityLineItem oli = null;
        OpportunityLineItem oli2 = null;
        OpportunityLineItem oli3 = null;
        Product2 produto = null;
        Pricebook2 pricebook = null;
        PricebookEntry pbe = null;
        List<RecordType> listRecType = null;
        List<String> developerName = null;
        Map<String, String> mapRecType = null;
        String idAccount = null;
        String idOpportunity = null;
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );

        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];

        System.runAs(thisUser){
             usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
             insert usuario;
        }

        System.runAs(usuario){
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c = '01';
            regional.CodUs__c = '01';
            regional.Internal_Id__c = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c = '01';
            bandeira.CodUs__c = '06';
            bandeira.Internal_Id__c = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;

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

            //produto = [Select Id, Name, Sku__c From Product2 Where Sku__c = '146' AND Qtlimit 1];

            produto = new Product2();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.IsActive = true;
            produto.CD_Unit__c = 'UN';
            produto.Internal_id__c = '146';
            produto.QT_lead_time__c = 5;
            produto.SKU__c = '444';
            produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
            insert produto;

            //Recupera o catalogo de preço padrão
            List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1];

            //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            insert entradaCatalogoPreco;

            //Recupera os IDS de tipo de registro.
            idOpportunity = RecordTypeForTest.getRecType('Opportunity','OPP_1_NewOrder_ARG');

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
            oli.OpportunityId = opp.Id;
            oli.UnitPrice = 12;
            oli.Quantity = 12;
            insert oli;
            /*
            //Cria um novo produto da oportunidade.
            oli2 = new OpportunityLineItem();
            oli2.PricebookEntryId = entradaCatalogoPreco.Id;
            oli2.OpportunityId = opp.Id;
            oli2.UnitPrice = 12;
            oli2.Quantity = 12;
            insert oli2;

            //Cria um novo produto da oportunidade.
            oli3 = new OpportunityLineItem();
            oli3.PricebookEntryId = entradaCatalogoPreco.Id;
            oli3.OpportunityId = opp.Id;
            oli3.UnitPrice = 12;
            oli3.Quantity = 12;
            insert oli3;*/
            List<OpportunityLineItem> lOli = new List<OpportunityLineItem>();
            lOli.add(oli);
            /*lOli.add(oli2);
            lOli.add(oli3);*/
            Test.startTest();
            Utils.setMigrationDoneTest(false);
            String lIdOpp = opp.Id;
            WS04_PriceCalculationInterface_AR.PriceCalculation(lIdOpp);
            WS04_PriceCalculationInterface_AR.PriceCalculation2(lIdOpp, lOli);
            WS04_PriceCalculationInterface_AR.getConnectionParameter('Argentina');
            Test.stopTest();
        }
    }

    static testMethod void PriceCalculationInterfaceTestB(){
        Utils.setMigrationDoneTest(true);
        insert createProcessingVersionXCountry('6','SO');
        CS001_JDEInterfaceCredentials__c csARG = [SELECT id, Exec_new_Price_Calc__c FROM CS001_JDEInterfaceCredentials__c WHERE Country__c = '6'];
        csARG.Exec_new_Price_Calc__c = true;
        update csARG;
        //Declaração de variáveis.
        Account acc = null;
        UDC__c regional, bandeira, cidade = null;
        LAT_Opportunity__c opp = null;
        User usuario = null;
        LAT_OpportunityLineItem__c oli = null;
        LAT_OpportunityLineItem__c oli2 = null;
        LAT_OpportunityLineItem__c oli3 = null;
        LAT_Product__c produto = null;
        Pricebook2 pricebook = null;
        PricebookEntry pbe = null;
        List<RecordType> listRecType = null;
        List<String> developerName = null;
        Map<String, String> mapRecType = null;
        String idAccount = null;
        String idOpportunity = null;
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );

        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];

        System.runAs(thisUser){
             usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
             insert usuario;
        }

        System.runAs(usuario){
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c = '01';
            regional.CodUs__c = '01';
            regional.Internal_Id__c = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c = '01';
            bandeira.CodUs__c = '06';
            bandeira.Internal_Id__c = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;

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

            //produto = [Select Id, Name, Sku__c From Product2 Where Sku__c = '146' AND Qtlimit 1];

            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '146';
            produto.LAT_QTLeadTime__c = 5;
            produto.LAT_Sku__c = '444';
            produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
            insert produto;


            //Recupera os IDS de tipo de registro.
            idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

            //Cria nova oportunidade.
            opp = new LAT_Opportunity__c();
            opp.Name = 'Opp TESTE COTA';
            opp.LAT_CloseDate__c = System.today()+1;
            opp.RecordTypeId = idOpportunity;
            opp.LAT_Account__c = acc.Id;
            opp.LAT_StageName__c = 'Novo Pedido';
            opp.LAT_Type__c = 'SO';
            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c = opp.Id;
            oli.LAT_UnitPrice__c = 12;
            oli.LAT_Quantity__c = 12;
            insert oli;
            /*
            //Cria um novo produto da oportunidade.
            oli2 = new OpportunityLineItem();
            oli2.PricebookEntryId = entradaCatalogoPreco.Id;
            oli2.OpportunityId = opp.Id;
            oli2.UnitPrice = 12;
            oli2.Quantity = 12;
            insert oli2;

            //Cria um novo produto da oportunidade.
            oli3 = new OpportunityLineItem();
            oli3.PricebookEntryId = entradaCatalogoPreco.Id;
            oli3.OpportunityId = opp.Id;
            oli3.UnitPrice = 12;
            oli3.Quantity = 12;
            insert oli3;*/
            List<LAT_OpportunityLineItem__c> lOli = new List<LAT_OpportunityLineItem__c>();
            lOli.add(oli);
            /*lOli.add(oli2);
            lOli.add(oli3);*/

            String lIdOpp = opp.Id;
            Test.startTest();
            WS04_PriceCalculationInterface_AR.LAT_PriceCalculation(lIdOpp);
            WS04_PriceCalculationInterface_AR.LAT_PriceCalculation2(lIdOpp, lOli);
            WS04_PriceCalculationInterface_AR.getConnectionParameter('Argentina');
            LAT_BR_PriceCalculation.priceCatalogueHeaderOutput p = new LAT_BR_PriceCalculation.priceCatalogueHeaderOutput();
            LAT_BR_PriceCalculation.priceCatalogueDetailsOutput o = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput();
            LAT_BR_PriceCalculation.discountAndChargeDetailsOutput q = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
            LAT_BR_PriceCalculation.messageValueObject x = new LAT_BR_PriceCalculation.messageValueObject();
            LAT_BR_PriceCalculation.valueObject xq = new LAT_BR_PriceCalculation.valueObject();
            LAT_BR_PriceCalculation.BusinessServiceException_x x4 = new LAT_BR_PriceCalculation.BusinessServiceException_x();
            LAT_BR_PriceCalculation.e1MessageList xw = new LAT_BR_PriceCalculation.e1MessageList();
            LAT_BR_PriceCalculation.errorRecords xe = new LAT_BR_PriceCalculation.errorRecords();
            LAT_BR_PriceCalculation.e1Message xr = new LAT_BR_PriceCalculation.e1Message();
            LAT_BR_PriceCalculation.priceCatalogueDetailsInput xt = new LAT_BR_PriceCalculation.priceCatalogueDetailsInput();
            try {
                PriceCalculationInterface.LAT_BR_NewPriceCalculation(lIdOpp, lOli, false);
               
            } catch(Exception e) {}
            Test.stopTest();
        }

    }
    // Test.startTest();
    //
    // Test.stopTest();
    static testMethod void PriceCalculationInterfaceOldPrice(){
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Argentina');
        cred.Exec_new_Price_Calc__c = false;
        update cred;
        Utils.setMigrationDoneTest(true);
        //Declaração de variáveis.
        Account acc = null;
        UDC__c regional, bandeira, cidade = null;
        LAT_Opportunity__c opp = null;
        User usuario = null;
        LAT_OpportunityLineItem__c oli = null;
        LAT_OpportunityLineItem__c oli2 = null;
        LAT_OpportunityLineItem__c oli3 = null;
        LAT_Product__c produto = null;
        Pricebook2 pricebook = null;
        PricebookEntry pbe = null;
        List<RecordType> listRecType = null;
        List<String> developerName = null;
        Map<String, String> mapRecType = null;
        String idAccount = null;
        String idOpportunity = null;
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );

        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];

        System.runAs(thisUser){
             usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
             insert usuario;
        }

        System.runAs(usuario){
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c = '01';
            regional.CodUs__c = '01';
            regional.Internal_Id__c = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c = '01';
            bandeira.CodUs__c = '06';
            bandeira.Internal_Id__c = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;

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

            //produto = [Select Id, Name, Sku__c From Product2 Where Sku__c = '146' AND Qtlimit 1];

            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '146';
            produto.LAT_QTLeadTime__c = 5;
            produto.LAT_Sku__c = '444';
            produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
            insert produto;


            //Recupera os IDS de tipo de registro.
            idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

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
            oli.LAT_Opportunity__c = opp.Id;
            oli.LAT_UnitPrice__c = 12;
            oli.LAT_Quantity__c = 12;
            insert oli;
            /*
            //Cria um novo produto da oportunidade.
            oli2 = new OpportunityLineItem();
            oli2.PricebookEntryId = entradaCatalogoPreco.Id;
            oli2.OpportunityId = opp.Id;
            oli2.UnitPrice = 12;
            oli2.Quantity = 12;
            insert oli2;

            //Cria um novo produto da oportunidade.
            oli3 = new OpportunityLineItem();
            oli3.PricebookEntryId = entradaCatalogoPreco.Id;
            oli3.OpportunityId = opp.Id;
            oli3.UnitPrice = 12;
            oli3.Quantity = 12;
            insert oli3;*/
            List<LAT_OpportunityLineItem__c> lOli = new List<LAT_OpportunityLineItem__c>();
            lOli.add(oli);
            /*lOli.add(oli2);
            lOli.add(oli3);*/

            String lIdOpp = opp.Id;
            WS04_PriceCalculationInterface_AR.LAT_PriceCalculation(lIdOpp);
            //WS04_PriceCalculationInterface_AR.LAT_PriceCalculation2(lIdOpp, lOli);
            WS04_PriceCalculationInterface_AR.getConnectionParameter('Argentina');
        }
    }

    static testMethod void PriceCalculationInterfaceOldPrice2(){
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Argentina');
        cred.Exec_new_Price_Calc__c = false;
        update cred;
        Utils.setMigrationDoneTest(true);
        //Declaração de variáveis.
        Account acc = null;
        UDC__c regional, bandeira, cidade = null;
        LAT_Opportunity__c opp = null;
        User usuario = null;
        LAT_OpportunityLineItem__c oli = null;
        LAT_OpportunityLineItem__c oli2 = null;
        LAT_OpportunityLineItem__c oli3 = null;
        LAT_Product__c produto = null;
        Pricebook2 pricebook = null;
        PricebookEntry pbe = null;
        List<RecordType> listRecType = null;
        List<String> developerName = null;
        Map<String, String> mapRecType = null;
        String idAccount = null;
        String idOpportunity = null;
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );

        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        User thisUser = [select Id from User where Id = :UserInfo.getUserId()];

        System.runAs(thisUser){
             usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
             insert usuario;
        }

        System.runAs(usuario){
            //Cria nova UDC.
            regional = new UDC__c();
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c = '01';
            regional.CodUs__c = '01';
            regional.Internal_Id__c = '1234';
            regional.RecordTypeId = idRecTypeUDC;
            insert regional;

            //Cria nova UDC.
            bandeira = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c = '01';
            bandeira.CodUs__c = '06';
            bandeira.Internal_Id__c = '1236';
            bandeira.RecordTypeId = idRecTypeUDC;
            insert bandeira;

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

            //produto = [Select Id, Name, Sku__c From Product2 Where Sku__c = '146' AND Qtlimit 1];

            produto = new LAT_Product__c();
            produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
            produto.LAT_IsActive__c = true;
            produto.LAT_CDUnit__c = 'UN';
            produto.LAT_ExternalId__c = '146';
            produto.LAT_QTLeadTime__c = 5;
            produto.LAT_Sku__c = '444';
            produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
            insert produto;


            //Recupera os IDS de tipo de registro.
            idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

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
            oli.LAT_Opportunity__c = opp.Id;
            oli.LAT_UnitPrice__c = 12;
            oli.LAT_Quantity__c = 12;
            insert oli;
            /*
            //Cria um novo produto da oportunidade.
            oli2 = new OpportunityLineItem();
            oli2.PricebookEntryId = entradaCatalogoPreco.Id;
            oli2.OpportunityId = opp.Id;
            oli2.UnitPrice = 12;
            oli2.Quantity = 12;
            insert oli2;

            //Cria um novo produto da oportunidade.
            oli3 = new OpportunityLineItem();
            oli3.PricebookEntryId = entradaCatalogoPreco.Id;
            oli3.OpportunityId = opp.Id;
            oli3.UnitPrice = 12;
            oli3.Quantity = 12;
            insert oli3;*/
            List<LAT_OpportunityLineItem__c> lOli = new List<LAT_OpportunityLineItem__c>();
            lOli.add(oli);
            /*lOli.add(oli2);
            lOli.add(oli3);*/

            String lIdOpp = opp.Id;
            //WS04_PriceCalculationInterface_AR.LAT_PriceCalculation(lIdOpp);
            WS04_PriceCalculationInterface_AR.LAT_PriceCalculationFromOrderHandler(lIdOpp, lOli);
            WS04_PriceCalculationInterface_AR.getConnectionParameter('Argentina');
        }

    }
}