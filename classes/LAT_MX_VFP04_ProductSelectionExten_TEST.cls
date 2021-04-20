/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:04/12/2013    *
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 11/11/2016
*
********************************************************************************/

@istest(seeAllDAta=true)
public with sharing class LAT_MX_VFP04_ProductSelectionExten_TEST {

    /*
    static testMethod void unitTest() {
        Utils.setMigrationDoneTest(false);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            Client_code_AN8__c = '100',
            Client_country_AN8__c = '12-100',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        //update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        test.startTest();
        Utils.setMigrationDoneTest(false);
        insert opp;
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 


        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB.Id, 
            IsActive = true,
            UseStandardPrice = false
        );
        
        insert pbe3;
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            cd_line_status__c = '1',
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(pbe3);
                
        //System.Test.startTest();
        //oPEE.doPrevious();
        //oPEE.doNext();
       // oPEE.doSearchProducts();
        //oPEE.doAddItemsToShoppingCart();
       // oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
       // oPEE.doClosePopup();
        oPEE.doSave();
        oPEE.doCancel();
        
        test.stopTest();   
       
    }
*/
   static testMethod void unitTestb() {
        Utils.setMigrationDoneTest(true);
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@test.com');
        //insert cfg2;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='123456789013',  RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'));
        
        insert udc;
        insert paymentCondition;

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5661',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.LAT_Product__c = prod1.Id;
        app.Payment__c = paymentCondition.Id;
        app.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app;
        
        LAT_Account_product_payment__c app2 = new LAT_Account_product_payment__c();
        app2.Account__c = acc.Id;
        app2.LAT_Product__c = prod2.Id;
        app2.Payment__c = paymentCondition.Id;
        app2.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app2;
    
        System.Test.startTest();
        Utils.setMigrationDoneTest(true); 
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_C9Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_cdlinestatus__c = '1',
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(prod1);
                
        //System.Test.startTest();
        //oPEE.doPrevious();
        //oPEE.doNext();
       // oPEE.doSearchProducts();
        //oPEE.doAddItemsToShoppingCart();
       // oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
       // oPEE.doClosePopup();
        oPEE.doSave();
        oPEE.doCancel();
        
        test.stopTest();   
       
    }

   static testMethod void unitTestCC() {
        Utils.setMigrationDoneTest(false);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            Client_code_AN8__c = '100',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        //update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 

        test.startTest();
        Utils.setMigrationDoneTest(false);
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB.Id, 
            IsActive = true,
            UseStandardPrice = false
        );
        
        insert pbe3;
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(pbe3);
                
        //System.Test.startTest();
        //oPEE.doPrevious();
        //oPEE.doNext();
       // oPEE.doSearchProducts();
        //oPEE.doAddItemsToShoppingCart();
       // oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
       // oPEE.doClosePopup();
        oPEE.doSave();
        oPEE.doCancel();
        
        test.stopTest();   
       
    }

   static testMethod void unitTestC() {
        Utils.setMigrationDoneTest(true);
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@test.com');
        //insert cfg2;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='123456789013',  RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'));
        
        insert udc;
        insert paymentCondition;

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5661',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.LAT_Product__c = prod1.Id;
        app.Payment__c = paymentCondition.Id;
        app.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app;
        
        LAT_Account_product_payment__c app2 = new LAT_Account_product_payment__c();
        app2.Account__c = acc.Id;
        app2.LAT_Product__c = prod2.Id;
        app2.Payment__c = paymentCondition.Id;
        app2.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app2;
    
        System.Test.startTest();
        Utils.setMigrationDoneTest(true); 
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_C9Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(prod1);
                
        //System.Test.startTest();
        //oPEE.doPrevious();
        //oPEE.doNext();
       // oPEE.doSearchProducts();
        //oPEE.doAddItemsToShoppingCart();
       // oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
       // oPEE.doClosePopup();
        oPEE.doSave();
        oPEE.doCancel();
        oPEE.doCheckAvailability();
        
        test.stopTest();   
       
    }
    
    static testMethod void unitTest1() {
        Utils.setMigrationDoneTest(false);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            SaveDuplicatedFiscalID_AR__c = true,
            Client_code_AN8__c = '100',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        //update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 

        //        test.startTest();
        System.Test.startTest();
        Utils.setMigrationDoneTest(false);        
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB.Id, 
            IsActive = true,
            UseStandardPrice = false
        );
        
        insert pbe3;
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(pbe3);
                
        //System.Test.startTest();
        oPEE.doPrevious();
        oPEE.doNext();
        oPEE.doSearchProducts();
        //oPEE.doAddItemsToShoppingCart();
        //oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
        //oPEE.doClosePopup();
     
        
        test.stopTest();  
    }
    
    static testMethod void unitTest1b() {
        Utils.setMigrationDoneTest(true);
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@test.com');
        //insert cfg2;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='123456789013',  RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'));
        
        insert udc;
        insert paymentCondition;

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            SaveDuplicatedFiscalID_AR__c = true,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5661',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.LAT_Product__c = prod1.Id;
        app.Payment__c = paymentCondition.Id;
        app.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app;
        
        LAT_Account_product_payment__c app2 = new LAT_Account_product_payment__c();
        app2.Account__c = acc.Id;
        app2.LAT_Product__c = prod2.Id;
        app2.Payment__c = paymentCondition.Id;
        app2.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app2;


        System.Test.startTest();
        Utils.setMigrationDoneTest(true);         
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;

        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_C9Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;        
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(prod1);
                
        //System.Test.startTest();
        oPEE.doPrevious();
        oPEE.doNext();
        oPEE.doSearchProducts();
        //oPEE.doAddItemsToShoppingCart();
        //oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
        //oPEE.doClosePopup();
     
        
        test.stopTest();  
    }

    static testMethod void unitTest2() {
        Utils.setMigrationDoneTest(false);        
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            SaveDuplicatedFiscalID_AR__c = true,
            Client_code_AN8__c = '100',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        //update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 

        //        test.startTest();
        System.Test.startTest();
        Utils.setMigrationDoneTest(false);          
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB.Id, 
            IsActive = true,
            UseStandardPrice = false
        );
        
        insert pbe3;
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(pbe3);
        oPEE.listAvailableProductsWrapper.add(pw);        
        //System.Test.startTest();
        //oPEE.doPrevious();
        //oPEE.doNext();
        //oPEE.doSearchProducts();
        oPEE.doAddItemsToShoppingCart();
        //oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
        //oPEE.doClosePopup();
     
        
        test.stopTest();  
    }

    static testMethod void unitTest2b() {
        Utils.setMigrationDoneTest(true);   
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@test.com');
        //insert cfg2;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='123456789013',  RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'));
        
        insert udc;
        insert paymentCondition;

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = paymentCondition.id,
            SaveDuplicatedFiscalID_AR__c = true,
            Client_country_AN8__c = '25',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        

        insert acc;
        
        acc.Client_code_AN8__c = '12000000';
        
        update acc;

         System.debug( '############################ &' + acc.Client_code_AN8__c);

        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            LAT_MX_OrderPaymentPeriodReference__c = paymentCondition.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        System.debug( '############################ &2' + acc.Client_code_AN8__c);

        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5661',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod2;
        System.debug( '############################ &3' + acc.Client_code_AN8__c);

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.LAT_Product__c = prod1.Id;
        app.Payment__c = paymentCondition.Id;
        app.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app;
        
        LAT_Account_product_payment__c app2 = new LAT_Account_product_payment__c();
        app2.Account__c = acc.Id;
        app2.LAT_Product__c = prod2.Id;
        app2.Payment__c = paymentCondition.Id;
        app2.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app2;


        System.debug( '############################ &4' + acc.Client_code_AN8__c);

        //        test.startTest();
        System.Test.startTest();
        Utils.setMigrationDoneTest(true);          

        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );

        LAT_MX_QTA_Quota__c quota2 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod2.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota2;

        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_C9Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;    
        
        System.debug( '############################ &5 ' + acc.Client_code_AN8__c + ' id : '+acc.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(prod1);
        oPEE.listAvailableProductsWrapper.add(pw);
        oPEE.LAT_theOpp.LAT_Account__r.Client_country_AN8__c = '12000000';
        //System.Test.startTest();
        oPEE.doPrevious();
        oPEE.doNext();
        oPEE.doSearchProducts();
        oPEE.doAddItemsToShoppingCart();
        //oPEE.doRemoveFromShoppingCart();
        //oPEE.doShowPopup();
        //oPEE.doClosePopup();
        System.debug( '############################ &6' + acc.Client_code_AN8__c);

        
        test.stopTest();  
    }    

    static testMethod void unitTest3() {
              
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            SaveDuplicatedFiscalID_AR__c = true,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 

        //        test.startTest();
        //System.Test.startTest();
        //Utils.setMigrationDoneTest(false);          
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB.Id, 
            IsActive = true,
            UseStandardPrice = false
        );
        
        insert pbe3;
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        System.Test.startTest();
        Utils.setMigrationDoneTest(false);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(pbe3);
        oPEE.listAvailableProductsWrapper.add(pw);        
         
        //oPEE.doPrevious();
        //oPEE.doNext();
        //oPEE.doSearchProducts();
        oPEE.doAddItemsToShoppingCart();
        oPEE.doRemoveFromShoppingCart();
        oPEE.doShowPopup();
        oPEE.doClosePopup();
     
        
        test.stopTest();  
    }

    static testMethod void unitTest3b() {
        Utils.setMigrationDoneTest(true);       
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@test.com');
        //insert cfg2;
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='123456789013',  RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'));
        
        insert udc;
        insert paymentCondition;

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = paymentCondition.id,
            SaveDuplicatedFiscalID_AR__c = true,
            Client_country_AN8__c = '25',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        

        insert acc;
        
        acc.Client_code_AN8__c = '12000000';
        
        update acc;

         System.debug( '############################ &' + acc.Client_code_AN8__c);

        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            LAT_MX_OrderPaymentPeriodReference__c = paymentCondition.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        System.debug( '############################ &2' + acc.Client_code_AN8__c);

        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5661',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod2;
        System.debug( '############################ &3' + acc.Client_code_AN8__c);

        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c();
        app.Account__c = acc.Id;
        app.LAT_Product__c = prod1.Id;
        app.Payment__c = paymentCondition.Id;
        app.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app;
        
        LAT_Account_product_payment__c app2 = new LAT_Account_product_payment__c();
        app2.Account__c = acc.Id;
        app2.LAT_Product__c = prod2.Id;
        app2.Payment__c = paymentCondition.Id;
        app2.CustomerCountryAN8Code__c = acc.Client_country_AN8__c;
        insert app2;


        System.debug( '############################ &4' + acc.Client_code_AN8__c);

        //        test.startTest();
        System.Test.startTest();
        Utils.setMigrationDoneTest(true);          

        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );

        LAT_MX_QTA_Quota__c quota2 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod2.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota2;

        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_C9Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;    
        
        System.debug( '############################ &5 ' + acc.Client_code_AN8__c + ' id : '+acc.Id);

        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(prod1);
        oPEE.listAvailableProductsWrapper.add(pw);
        oPEE.LAT_theOpp.LAT_Account__r.Client_country_AN8__c = '12000000';
        //System.Test.startTest();
        //oPEE.doPrevious();
        //oPEE.doNext();
        //oPEE.doSearchProducts();
        oPEE.doAddItemsToShoppingCart();
        oPEE.doRemoveFromShoppingCart();
        oPEE.doShowPopup();
        oPEE.doClosePopup();
        System.debug( '############################ &6' + acc.Client_code_AN8__c);

        
        test.stopTest();  
    } 
/*
    static testMethod void unitTest3() {

        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            SaveDuplicatedFiscalID_AR__c = true,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;


        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 

        
        System.Test.startTest();
        
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB.Id, 
            IsActive = true,
            UseStandardPrice = false
        );
        
        insert pbe3;
        
       // test.startTest();
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        
        insert oli;
        //System.Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_MX_VFP04_ProductSelectionExtension oPEE = new LAT_MX_VFP04_ProductSelectionExtension(controller);
        LAT_MX_VFP04_ProductSelectionExtension.productWrapper pw = new LAT_MX_VFP04_ProductSelectionExtension.productWrapper(pbe3);
                
        //System.Test.startTest();
        oPEE.doPrevious();
        oPEE.doNext();
        oPEE.doSearchProducts();
        oPEE.doAddItemsToShoppingCart();
        oPEE.doRemoveFromShoppingCart();
        oPEE.doAddItemsToShoppingCart();
        oPEE.doShowPopup();
        oPEE.doClosePopup();
     
        test.stopTest();  
         
    }*/
}