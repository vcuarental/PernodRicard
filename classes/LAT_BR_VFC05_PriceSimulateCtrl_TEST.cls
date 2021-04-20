/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
 
 Modification
 Date: 23/04/2015
 Staff: Mariano Boezio
 Description: 
     - Removed See all data
     - Added Standard PriceBook
     - Create Configuration CS
     - Moved the StartTest method
****************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/
@isTest
public with sharing class LAT_BR_VFC05_PriceSimulateCtrl_TEST {
    
    static testmethod void unitTest(){
        Utils.setMigrationDoneTest(false);
        Set<String> setDeInternalIds = new Set<String>{'01-06', '01-01', 'CRM-DF'}; 
        
        // Configuration
        LAT_BR_CS003_OppLimitTime__c timeLimit = new LAT_BR_CS003_OppLimitTime__c();
        timeLimit.LAT_BR_HH__c = 1;
        timeLimit.LAT_BR_MM__c = 1;
        insert timeLimit;
        
        //Criacao das novas UDC
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
        delete [SELECT id, Name, Internal_Id__c FROM UDC__c WHERE Internal_Id__c IN: setDeInternalIds];
        UDC__c regional = new UDC__c(
            CodDefUsuario__c='4546', 
            CodProd__c='01', 
            CodUs__c='01', 
            Internal_Id__c='01-01', 
            RecordTypeId = idRecTypeUDC
        );
        UDC__c customerFlag = new UDC__c(
            CodDefUsuario__c='179', 
            CodProd__c='01', 
            CodUs__c='06', 
            Internal_Id__c='01-06', 
            RecordTypeId = idRecTypeUDC
        );
        UDC__c businessUnit = new UDC__c(
            CodDefUsuario__c='03', 
            CodProd__c='CRM', 
            CodUs__c='DF', 
            Internal_Id__c='CRM-DF', 
            RecordTypeId = idRecTypeUDC
        );
        UDC__c paymentCondition = new UDC__c(
            Name = 'test paymentConditionA',
            CodDefUsuario__c='06', 
            CodProd__c='CRM', 
            CodUs__c='DF', 
            Internal_Id__c='1237 CRM-PT', 
            RecordTypeId = idRecTypeUDC
        );
        List<UDC__c> udcs = new List<UDC__c>{regional, customerFlag, businessUnit, paymentCondition};
        insert udcs;
        
        //Cria novo Account
        Account acc = new Account(
            Name = 'ProdutosOppVerificaCotaExistenteTeste',
            Status__c = 'Cliente cadastrado no JDE',
            Frequency_of_Visits__c = 'Semanal',
            Client_code_AN8__c = '557799',
            Corporate_Name__c = 'Teste',
            Checking_account__c = '000',
            Carriers_Numbers__c = '123',
            CNPJ__c = '48843971000120',
            Current_account__c = '0',
            Payment_Condition__c = paymentCondition.Id,
            Channel__c = 'Off Trade',
            Price_Group__c = '1',
            Agency__c = '000',
            Type = 'Outros',
            Regional__c = regional.Id,
            Customer_Flag__c = customerFlag.Id,
            Business_Unit__c = businessUnit.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')
        );
        insert acc;
        
        Product2 produto = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CurrencyIsoCode = 'BRL',
            CD_Unit__c = 'UN',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            LAT_IsRefactorProduct__c = 'Y',           
            RecordTypeId = Global_RecordTypeCache.getRtId( 'Product2' + 'BRA_Standard')
        );
        insert produto;

        Product2 produto2 = new Product2(
            Name = 'TestProd2',
            IsActive = true,
            CurrencyIsoCode = 'BRL',
            CD_Unit__c = 'UN',
            Internal_id__c = '4442',
            QT_lead_time__c = 5,
            SKU__c = '56662',
            LAT_IsRefactorProduct__c = 'Y',           
            RecordTypeId = Global_RecordTypeCache.getRtId( 'Product2' + 'BRA_Standard')
        );
        insert produto2;
        
        // Creating Standard Price Book Entry
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = produto.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
                
        //Cria novo pricebook
        Pricebook2 pricebook = new Pricebook2(Name = '1', Description = '1', IsActive =true);
        insert pricebook;
        
         //Cria novo pricebook
        Pricebook2 pricebook2 = new Pricebook2(Name = '2', Description = '12', IsActive =true);
        insert pricebook2;
         //Cria novo pricebook
        Pricebook2 pricebook3 = new Pricebook2(Name = '2', Description = '13', IsActive =true);
        insert pricebook3;
        //Cria novo pricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = produto.Id,
            UnitPrice = 12,
            Pricebook2Id = pricebook.Id,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        
        /*/Cria novo pricebookEntry
        PricebookEntry pbe2 = new PricebookEntry(
            Product2Id = produto2.Id,
            UnitPrice = 22,
            Pricebook2Id = pricebook2.Id,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe2;

        //Cria novo pricebookEntry
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = produto.Id,
            UnitPrice = 32,
            Pricebook2Id = pricebook3.Id,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe3;*/

        //Cria nova oportunidade.
        Opportunity opp = new Opportunity(
            Name = 'Opp TESTE COTA',
            closeDate = Date.today().addDays(1),
            AccountId = acc.Id,
            StageName = 'Novo Pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade')
        );
        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            PricebookEntryId = pbe.Id,
            OpportunityId =opp.Id,
            UnitPrice = 12,
            Quantity = 12,
            Percentual_de_bonus__c = 3
        );
        insert oli;
        /*
        OpportunityLineItem oli2 = new OpportunityLineItem(
            PricebookEntryId = pbe2.Id,
            OpportunityId =opp.Id,
            UnitPrice = 12,
            Quantity = 12,
            QT_Bonus__c = 4
        );
        insert oli2;

        OpportunityLineItem oli3 = new OpportunityLineItem(
            PricebookEntryId = pbe3.Id,
            OpportunityId =opp.Id,
            UnitPrice = 12,
            Quantity = 12,
            QT_Bonus__c = 4,
            Percentual_de_bonus__c = 3
        );
        insert oli3;*/
        
        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c(
            PaymentConditionDescription__c = paymentCondition.Name,
            PaymentCondition__c = paymentCondition.CodDefUsuario__c,
            Account__c = acc.Id,
            Product__c = produto.Id,
            Payment__c = paymentCondition.Id,
            ProductExternalId__c = produto.Internal_id__c,
            CustomerCountryAN8Code__c = acc.Client_country_AN8__c,           
            PaymentConditionExternalId__c = paymentCondition.Internal_Id__c
        );
        insert app;     
         
        test.StartTest();
        
            //Test of class "opportunityProductEntryExtension"
            ApexPages.currentPage().getParameters().put('idAcc', acc.Id);

            System.debug('%%%%%%%%%%%%%%%%%%%%%% en Test AccountId : '+acc.Id+ '--'+ApexPages.currentPage().getparameters().get('idAcc'));
            LAT_BR_VFC05_PriceSimulateCtrl oPEE = new LAT_BR_VFC05_PriceSimulateCtrl();        
            LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart psc = new LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart(oli);
            //LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart psc2 = new LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart(oli2);
            //LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart psc3 = new LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart(oli3);
            LAT_BR_VFC05_PriceSimulateCtrl.productWrapper pw = new LAT_BR_VFC05_PriceSimulateCtrl.productWrapper(app);
            List<LAT_Account_product_payment__c> lstApp = new List<LAT_Account_product_payment__c> {app};
            oPEE.loadPagerTest(lstApp);
            oPEE.accId = acc.Id;

            oPEE.doPrevious();
            oPEE.doNext();
            oPEE.doAllResumed();
            oPEE.loadPagerTest(lstApp);                            
            oPEE.doSearchProducts();
            oPEE.doAddItemsToShoppingCart();
            oPEE.doRemoveFromShoppingCart();            
            oPEE.ShoppingCart.add(psc);            
            //oPEE.ShoppingCart.add(psc2);            
            //oPEE.ShoppingCart.add(psc3);
            oPEE.doSave();
            oPEE.doCalculatePrice();
            oPEE.loadPagerTest(lstApp);
            //MODIFIED  BY GDT 23 April 2015
            oPEE.doClean();
            oPEE.doChangePaymentCondition();
            oPEE.doShowPopup();
            oPEE.doClosePopup();
            oPEE.doCancel();
        
        test.StopTest();
    }

        static testmethod void unitTest2(){
        Utils.setMigrationDoneTest(true);
        Set<String> setDeInternalIds = new Set<String>{'01-06', '01-01', 'CRM-DF'}; 
        
        // Configuration
        LAT_BR_CS003_OppLimitTime__c timeLimit = new LAT_BR_CS003_OppLimitTime__c();
        timeLimit.LAT_BR_HH__c = 1;
        timeLimit.LAT_BR_MM__c = 1;
        insert timeLimit;
        
        //Criacao das novas UDC
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
        delete [SELECT id, Name, Internal_Id__c FROM UDC__c WHERE Internal_Id__c IN: setDeInternalIds];
        UDC__c regional = new UDC__c(
            CodDefUsuario__c='4546', 
            CodProd__c='01', 
            CodUs__c='01', 
            Internal_Id__c='01-01', 
            RecordTypeId = idRecTypeUDC
        );
        UDC__c customerFlag = new UDC__c(
            CodDefUsuario__c='179', 
            CodProd__c='01', 
            CodUs__c='06', 
            Internal_Id__c='01-06', 
            RecordTypeId = idRecTypeUDC
        );
        UDC__c businessUnit = new UDC__c(
            CodDefUsuario__c='03', 
            CodProd__c='CRM', 
            CodUs__c='DF', 
            Internal_Id__c='CRM-DF', 
            RecordTypeId = idRecTypeUDC
        );
        UDC__c paymentCondition = new UDC__c(
            Name = 'test paymentCondition',
            CodDefUsuario__c='06', 
            CodProd__c='CRM', 
            CodUs__c='DF', 
            Internal_Id__c='1237 CRM-PT', 
            RecordTypeId = idRecTypeUDC
        );
        List<UDC__c> udcs = new List<UDC__c>{regional, customerFlag, businessUnit, paymentCondition};
        insert udcs;
        
        //Cria novo Account
        Account acc = new Account(
            Name = 'ProdutosOppVerificaCotaExistenteTeste',
            Status__c = 'Cliente cadastrado no JDE',
            Frequency_of_Visits__c = 'Semanal',
            Client_code_AN8__c = '557799',
            Corporate_Name__c = 'Teste',
            Checking_account__c = '000',
            Carriers_Numbers__c = '123',
            CNPJ__c = '48843971000120',
            Payment_Condition__c = paymentCondition.Id,
            Current_account__c = '0',
            Channel__c = 'Off Trade',
            Price_Group__c = '1',
            Agency__c = '000',
            Type = 'Outros',
            Regional__c = regional.Id,
            Customer_Flag__c = customerFlag.Id,
            Business_Unit__c = businessUnit.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')
        );
        insert acc;
        
        LAT_Product__c produto = new LAT_Product__c(
            Name = 'TestProd',
            CurrencyIsoCode = 'BRL',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'UN',
            LAT_ExternalID__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            LAT_IsRefactorProduct__c = 'Y',           
            RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c' + 'BRA_Standard')
        );
        insert produto;
        
        LAT_Product__c produto2 = new LAT_Product__c(
            Name = 'TestProd2',
            CurrencyIsoCode = 'BRL',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'UN',
            LAT_ExternalID__c = '555',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5664',
            LAT_IsRefactorProduct__c = 'Y',           
            RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c' + 'BRA_Standard')
        );
        insert produto2;

        LAT_Product__c produto3 = new LAT_Product__c(
            Name = 'TestProd3',
            CurrencyIsoCode = 'BRL',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'UN',
            LAT_ExternalID__c = '555',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5662',
            LAT_IsRefactorProduct__c = 'Y',           
            RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c' + 'BRA_Standard')
        );
        insert produto3;

        //Cria nova oportunidade.
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            Name = 'Opp TESTE COTA',
            LAT_CloseDate__c = Date.today().addDays(1),
            LAT_Account__c = acc.Id,
            LAT_StageName__c = 'Novo Pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade')
        );
        insert opp;
        
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Product__c = produto.Id,
            LAT_Opportunity__c =opp.Id,
            LAT_UnitPrice__c = 12,
            LAT_PercentualOfBonus__c = 3,
            LAT_Quantity__c = 12
        );
        insert oli;

        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(
            LAT_Product__c = produto2.Id,
            LAT_Opportunity__c =opp.Id,
            LAT_UnitPrice__c = 12,
            LAT_QTBonus__c = 4,
            LAT_Quantity__c = 12
        );
        insert oli2;

        LAT_OpportunityLineItem__c oli4 = new LAT_OpportunityLineItem__c(
            LAT_Product__c = produto3.Id,
            LAT_Opportunity__c =opp.Id,
            LAT_UnitPrice__c = 12,
            LAT_QTBonus__c = 4,
            LAT_PercentualOfBonus__c = 3,
            LAT_Quantity__c = 12
        );
        insert oli4;
        
        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c(
            PaymentConditionDescription__c = paymentCondition.Name,
            PaymentCondition__c = paymentCondition.CodDefUsuario__c,
            Account__c = acc.Id,
            LAT_Product__c = produto.Id,
            Payment__c = paymentCondition.Id,
            ProductExternalId__c = produto.LAT_ExternalId__c,
            CustomerCountryAN8Code__c = acc.Client_country_AN8__c,           
            PaymentConditionExternalId__c = paymentCondition.Internal_Id__c
        );
        insert app;    
         
        test.StartTest();
        
            //Test of class "opportunityProductEntryExtension"
            ApexPages.currentPage().getParameters().put('idAcc', acc.Id);
            LAT_BR_VFC05_PriceSimulateCtrl oPEE = new LAT_BR_VFC05_PriceSimulateCtrl();        
            LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart psc = new LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart(oli);
            LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart psc2 = new LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart(oli2);
            LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart psc4 = new LAT_BR_VFC05_PriceSimulateCtrl.productShoppingCart(oli4);
            List<LAT_Account_product_payment__c> lstApp = new List<LAT_Account_product_payment__c> {app};
            oPEE.doAddItemsToShoppingCart();
            oPEE.loadPagerTest(lstApp);            
            oPEE.accId = acc.Id;
            oPEE.doAddItemsToShoppingCart();
            oPEE.accId = acc.Id;
            oPEE.doPrevious();
            oPEE.doNext();
            oPEE.doAllResumed();
            oPEE.loadPagerTest(lstApp);                
            oPEE.doSearchProducts();
            oPEE.doAddItemsToShoppingCart();
            oPEE.doRemoveFromShoppingCart();
            oPEE.loadPagerTest(lstApp);
            oPEE.ShoppingCart.add(psc);
            oPEE.ShoppingCart.add(psc2);
            oPEE.ShoppingCart.add(psc4);
            oPEE.doSave();
            oPEE.doCalculatePrice();
            //MODIFIED  BY GDT 23 April 2015
            oPEE.doClean();
            oPEE.loadPagerTest(lstApp);
            oPEE.doChangePaymentCondition();
            oPEE.doShowPopup();
            oPEE.doClosePopup();
            oPEE.doCancel();
        
        test.StopTest();
    }
}