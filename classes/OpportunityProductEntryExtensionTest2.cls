/******************************************************************************
*   Company:Valuenet    Developers:Waldemar Mayo       Date:/09/2013          *
*******************************************************************************/
 /********************************************************************************
*
* MIGRACION LICENCIAS
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/
@IsTest(seeAllData=true)
private class OpportunityProductEntryExtensionTest2 {

    static testMethod void unitTest(){
        Utils.setMigrationDoneTest(false);
        //Criacao das novas UDC
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__cBRA_Standard');
        UDC__c regional = new UDC__c(CodDefUsuario__c='4546', CodProd__c='01',  CodUs__c='01', Internal_Id__c='1234', RecordTypeId = idRecTypeUDC);
        UDC__c customerFlag = new UDC__c(CodDefUsuario__c='179',  CodProd__c='01',  CodUs__c='06', Internal_Id__c='1236', RecordTypeId = idRecTypeUDC);
        UDC__c businessUnit = new UDC__c(CodDefUsuario__c='05',   CodProd__c='CRM', CodUs__c='DF', Internal_Id__c='876',  RecordTypeId = idRecTypeUDC);
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='DF', Internal_Id__c='1237',  RecordTypeId = idRecTypeUDC);
        List<UDC__c> udcs = new List<UDC__c>{regional, customerFlag, businessUnit, paymentCondition};
        insert udcs;

        //Cria novo Account
        Account acc = new Account();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        acc.CNPJ__c = '48843971000120';
        acc.Current_account__c = '0';
        acc.Channel__c = 'Off Trade';
        acc.Price_Group__c = '1';
        acc.Agency__c = '000';
        acc.Type = 'Outros';
        //acc.Regional__c = regional.Id;
        //acc.Customer_Flag__c = customerFlag.Id;
        //acc.Business_Unit__c = businessUnit.Id;
        acc.RecordTypeId = Global_RecordTypeCache.getRtId('AccountOff_Trade');
        insert acc;

        Product2 produto = new Product2();
        produto.Name = 'TestProd';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        //produto.LAT_IsRefactorProduct__c = 'Y';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = Global_RecordTypeCache.getRtId( 'Product2BRA_Standard' );
        insert produto;

        Product2 produto2 = new Product2();
        produto2.Name = 'TestProd2';
        produto2.IsActive = true;
        produto2.CD_Unit__c = 'UN';
        produto2.Internal_id__c = '445';
        //produto.LAT_IsRefactorProduct__c = 'Y';
        //produto.QT_lead_time__c = 5;
        produto2.SKU__c = '5665';
        produto2.RecordTypeId = Global_RecordTypeCache.getRtId( 'Product2BRA_Standard' );
        insert produto2;


        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        PricebookEntry pbe2 = new PricebookEntry(Product2Id = produto.Id, UnitPrice = 12, Pricebook2Id = standardPB.Id, IsActive =true, UseStandardPrice = false,CurrencyIsoCode = 'USD');
        insert pbe2;

        produto.LAT_IsRefactorProduct__c = 'Y';
        update produto;

        produto2.LAT_IsRefactorProduct__c = 'Y';
        update produto2;
        //Cria novo pricebook
        Pricebook2 pricebook = new Pricebook2(Name = '1', Description = '1', IsActive=True);
        insert pricebook;
        Pricebook2 pricebook5 = new Pricebook2(Name = '5', Description = '5');
        insert pricebook5;

        //Cria novo pricebookEntry
        /*PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = produto2.Id;
        pbe.UnitPrice = 12;
        pbe.Pricebook2Id = pricebook.Id;
        pbe.IsActive =true;
        pbe.UseStandardPrice = false;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;*/

        //Cria nova oportunidade.
        Opportunity opp = new Opportunity();
        opp.CurrencyIsoCode = 'USD';
        opp.Name = 'Opp TESTE COTA';
        opp.closeDate = Date.today().addDays(1);
        opp.AccountId = acc.Id;
        opp.StageName = 'Novo Pedido';
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('OpportunityNova_oportunidade');
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe2.Id;
        oli.OpportunityId =opp.Id;
        oli.UnitPrice = 12;
        oli.Quantity = 12;
        //insert oli;

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.Product__c = produto.Id;
        app.Payment__c = paymentCondition.Id;
        insert app;

        LAT_Account_product_payment__c app2 = new LAT_Account_product_payment__c();
        app2.Account__c = acc.Id;
        app2.Product__c = produto2.Id;
        app2.Payment__c = paymentCondition.Id;
        insert app2;

        test.startTest();
        Utils.setMigrationDoneTest(false);
        //Test of class "opportunityProductEntryExtension"
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(controller);
        oPEE.theBook = pricebook5;
        opportunityProductEntryExtension.productWrapper pw = new opportunityProductEntryExtension.productWrapper(app);
        pw.isSelected = true;
        oPEE.lstWProducts.add(pw);
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.varPaymentVal = 'Todas';
        oPEE.updateAvailableListCheck();
        oPEE.addItensToShoppingCart();
        PageReference pr = oPEE.PaymentValues;
        LAT_Product__c pp = oPEE.LAT_theBook;
        //oPEE.showCampoFormatado();
        oPEE.searchString = produto2.Name;
        oPEE.paymentValues();
        oPEE.closePopup();
        oPEE.lstWProducts.add(pw);
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.getCondicao();
        oPEE.priceBookCheck();
        oPEE.getChosenCurrency();
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.getlstWProducts();
        oPEE.lstWProducts.add(pw);
        oPEE.onMsg();
        oPEE.removeFromShoppingCart();
        oPEE.onCancel();
        //oPEE.showCampoFormatado();oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.lstWProducts.add(pw);
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.getItemX();
        oPEE.showPopup();
        oPEE.priceBookCheck();
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.changePricebook();
        oPEE.initAction();
        oPEE.PriceCalculation2();
        oPEE.onSaveRefresh();
        oPEE.onSave();
        test.stopTest();
    }

   static testMethod void unitTestB(){

        Utils.setMigrationDoneTest(false);
        //Criacao das novas UDC
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__cBRA_Standard');
        UDC__c regional = new UDC__c(CodDefUsuario__c='4546', CodProd__c='01',  CodUs__c='01', Internal_Id__c='1234', RecordTypeId = idRecTypeUDC);
        UDC__c customerFlag = new UDC__c(CodDefUsuario__c='179',  CodProd__c='01',  CodUs__c='06', Internal_Id__c='1236', RecordTypeId = idRecTypeUDC);
        UDC__c businessUnit = new UDC__c(CodDefUsuario__c='05',   CodProd__c='CRM', CodUs__c='DF', Internal_Id__c='876',  RecordTypeId = idRecTypeUDC);
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='DF', Internal_Id__c='1237',  RecordTypeId = idRecTypeUDC);
        List<UDC__c> udcs = new List<UDC__c>{regional, customerFlag, businessUnit, paymentCondition};
        insert udcs;

        //Cria novo Account
        Account acc = new Account();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        acc.CNPJ__c = '48843971000120';
        acc.Current_account__c = '0';
        acc.Channel__c = 'Off Trade';
        acc.Price_Group__c = '1';
        acc.Agency__c = '000';
        acc.Type = 'Outros';
        //acc.Regional__c = regional.Id;
        //acc.Customer_Flag__c = customerFlag.Id;
        //acc.Business_Unit__c = businessUnit.Id;
        acc.RecordTypeId = Global_RecordTypeCache.getRtId('AccountOff_Trade');
        insert acc;

        Product2 produto = new Product2();
        produto.Name = 'TestProd';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '444';
        produto.LAT_IsRefactorProduct__c = 'Y';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '5666';
        produto.RecordTypeId = Global_RecordTypeCache.getRtId( 'Product2BRA_Standard' );
        insert produto;

        Product2 produto2 = new Product2();
        produto2.Name = 'TestProd2';
        produto2.IsActive = true;
        produto2.CD_Unit__c = 'UN';
        produto2.Internal_id__c = '445';
        produto2.LAT_IsRefactorProduct__c = 'Y';
        //produto.QT_lead_time__c = 5;
        produto2.SKU__c = '5663';
        produto2.RecordTypeId = Global_RecordTypeCache.getRtId( 'Product2BRA_Standard' );
        insert produto2;
        //Cria novo pricebook
        Pricebook2 pricebook = new Pricebook2(Name = '1', Description = '1');
        insert pricebook;
        Pricebook2 pricebook5 = new Pricebook2(Name = '5', Description = '5');
        insert pricebook5;
        id standardPBId = Test.getStandardPricebookId();
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];


        //Cria novo pricebookEntry
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = produto.Id;
        pbe.UnitPrice = 12;
        pbe.Pricebook2Id = pricebook.Id;
        pbe.IsActive =true;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UseStandardPrice = false;
        insert pbe;


        //pbe.Pricebook2Id = pricebook5.Id;
        //update pbe;
        //Cria nova oportunidade.
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp TESTE COTA';
        opp.closeDate = Date.today().addDays(1);
        opp.AccountId = acc.Id;
        opp.StageName = 'Novo Pedido';
        opp.CurrencyIsoCode = 'USD';
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('OpportunityNova_oportunidade');
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe.Id;
        oli.OpportunityId =opp.Id;
        oli.UnitPrice = 12;
        oli.Quantity = 12;
        //insert oli;

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.Product__c = produto.Id;
        app.Payment__c = paymentCondition.Id;
        insert app;

        test.startTest();
        Utils.setMigrationDoneTest(false);
        //Test of class "opportunityProductEntryExtension"
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(controller);
        opportunityProductEntryExtension.productWrapper pw = new opportunityProductEntryExtension.productWrapper(app);
        pw.isSelected =true;
        oPEE.theBook = pricebook5;
        oPEE.paymentValues();
        oPEE.closePopup();
        oPEE.getCondicao();
        oPEE.priceBookCheck();
        oPEE.getChosenCurrency();
        oPEE.getlstWProducts();
        oPEE.addItensToShoppingCart();
        oPEE.onMsg();
        oPEE.removeFromShoppingCart();
        oPEE.onCancel();
        //oPEE.showCampoFormatado();
        oPEE.getItemX();
        oPEE.showPopup();
        oPEE.priceBookCheck();
        oPEE.changePricebook();
        oPEE.initAction();
        oPEE.onSaveRefresh();
        oPEE.onSave();
        //oPEE.showCampoFormatado();
        test.stopTest();
    }


    static testMethod void unitTest2(){
        Utils.setMigrationDoneTest(true);
        //Criacao das novas UDC
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__cBRA_Standard');
        UDC__c regional = new UDC__c(CodDefUsuario__c='4546', CodProd__c='01',  CodUs__c='01', Internal_Id__c='1234', RecordTypeId = idRecTypeUDC);
        UDC__c customerFlag = new UDC__c(CodDefUsuario__c='179',  CodProd__c='01',  CodUs__c='06', Internal_Id__c='1236', RecordTypeId = idRecTypeUDC);
        UDC__c businessUnit = new UDC__c(CodDefUsuario__c='05',   CodProd__c='CRM', CodUs__c='DF', Internal_Id__c='876',  RecordTypeId = idRecTypeUDC);
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='DF', Internal_Id__c='1237',  RecordTypeId = idRecTypeUDC);
        List<UDC__c> udcs = new List<UDC__c>{regional, customerFlag, businessUnit, paymentCondition};
        insert udcs;

        //Cria novo Account
        Account acc = new Account();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        acc.CNPJ__c = '48843971000120';
        acc.Current_account__c = '0';
        acc.Channel__c = 'Off Trade';
        acc.Price_Group__c = '1';
        acc.Agency__c = '000';
        acc.Type = 'Outros';
        //acc.Regional__c = regional.Id;
        //acc.Customer_Flag__c = customerFlag.Id;
        //acc.Business_Unit__c = businessUnit.Id;
        acc.RecordTypeId = Global_RecordTypeCache.getRtId('AccountOff_Trade');
        insert acc;



        //Cria nova oportunidade.
        LAT_Opportunity__c opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = Date.today().addDays(1);
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';

        opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'Nova_oportunidade');
        insert opp;

        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'TestProd';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        produto.LAT_IsRefactorProduct__c = 'Y';
        //produto.QT_lead_time__c = 5;
        produto.CurrencyIsoCode = opp.CurrencyIsoCode;
        produto.LAT_Sku__c = '5666';
        produto.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+ 'BRA_Standard' );
        insert produto;

        LAT_Product__c produto2 = new LAT_Product__c();
        produto2.Name = 'TestProd2';
        produto2.LAT_IsActive__c = true;
        produto2.LAT_CDUnit__c = 'UN';
        produto2.LAT_ExternalId__c = '444';
        produto2.LAT_IsRefactorProduct__c = 'Y';
        //produto.QT_lead_time__c = 5;
        produto2.CurrencyIsoCode = opp.CurrencyIsoCode;
        produto2.LAT_Sku__c = '5667';
        produto2.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+ 'BRA_Standard' );
        insert produto2;

        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c =opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        //insert oli;

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.LAT_Product__c = produto2.Id;
        app.PaymentCondition__c = 'Cash';
        app.Payment__c = paymentCondition.Id;
        insert app;

        LAT_Account_product_payment__c app2 = new LAT_Account_product_payment__c();
        app2.Account__c = acc.Id;
        app2.LAT_Product__c = produto.Id;
        app2.PaymentCondition__c = 'Cash';
        app2.Payment__c = regional.Id;
        insert app2;

        test.startTest();
        Utils.setMigrationDoneTest(true);
        //Test of class "opportunityProductEntryExtension"
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        opportunityProductEntryExtension oPEE = new opportunityProductEntryExtension(controller);
        oPEE.searchString = produto.Name;
        oPEE.varPaymentVal = 'Cash';
        opportunityProductEntryExtension.productWrapper pw = new opportunityProductEntryExtension.productWrapper(app);

        oPEE.paymentValues();
        oPEE.lstWProducts.get(0).isSelected = true;

        oPEE.closePopup();
        oPEE.getCondicao();
        oPEE.priceBookCheck();
        oPEE.getChosenCurrency();
        oPEE.getlstWProducts();
        oPEE.addItensToShoppingCart();
        oPEE.onMsg();
        oPEE.removeFromShoppingCart();
        oPEE.onCancel();
        //oPEE.showCampoFormatado();
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.getItemX();
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.showPopup();
        oPEE.priceBookCheck();
        oPEE.changePricebook();
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.initAction();
        oPEE.lstWProducts.get(0).isSelected = true;
        oPEE.onSaveRefresh();
        oPEE.onSave();
        Utils.setMigrationDoneTest(true);
        oPEE.showCampoFormatado();
        test.stopTest();
    }
}