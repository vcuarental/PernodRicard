/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:04/12/2013    *
*******************************************************************************/

@istest(seeAllDAta=true)
public with sharing class LAT_MX_AP02_OpportunityProductsWOS_TEST {

    static testMethod void unitTest() {
        Utils.setMigrationDoneTest(false); 
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;
                    
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
            Credit_line__c = 1,
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            LAT_MX_AvailableCreditLimit__c = 1000,
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
        Id pricebookId = Test.getStandardPricebookId();
        
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
        
        system.test.startTest();
        Utils.setMigrationDoneTest(false);
        LAT_Utils.testOn = true;         
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),
            cd_line_status__c = '400',
            LAT_MX_CDLineStatusFrom__c = '540'
        );

        Database.SaveResult insertResult =  Database.insert(oli,false);
        System.assert(!insertResult.isSuccess());
        //insert oli;

        //oli.cd_line_status__c = '500';
        //update oli;
        
        system.test.stopTest();              
        
        LAT_Utils.testOn = false;         
        /*
        oli.cd_line_status__c = '400';
        oli.LAT_MX_CDLineStatusFrom__c = '540';
        
        update oli;
       
        oli.cd_line_status__c = '600';
        oli.LAT_MX_CDLineStatusFrom__c = '580';
        
        update oli; */
        
    }

    static testMethod void unitTest2() {
        Utils.setMigrationDoneTest(true); 
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;
                    
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            Credit_line__c = 1,
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            LAT_MX_AvailableCreditLimit__c = 1000,
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
            LAT_StageName__C = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        try{insert opp;} catch(exception e){}
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        try{insert prod1;} catch(exception e){}

        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '4442',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '56662',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        try{insert prod2;} catch(exception e){}
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        system.test.startTest();
        Utils.setMigrationDoneTest(true);       

        LAT_Utils.testOn = true;           
        
        LAT_OpportunityLineItem__c oli1 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_CdLineStatus__c = '400',
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_Quota__c = quota.Id
        );
        
        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 20,
            LAT_AR_UOM__c = 'CAa',
            LAT_SkuText__c = '1001',
            LAT_Product__c = prod2.Id,
            LAT_UnitPrice__c = 11,
            LAT_CdLineStatus__c = '400',
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_Quota__c = quota.Id
        );
        
        Database.SaveResult insertResult =  Database.insert(oli1,false);
        System.assert(!insertResult.isSuccess());

        Database.SaveResult insertResult2 =  Database.insert(oli2,false);
        System.assert(!insertResult2.isSuccess());
        //insert oli;        
        //insert new List<LAT_OpportunityLineItem__c>{oli1,oli2};
        system.test.stopTest();     

        LAT_Utils.testOn = false;                  
        
        /*
        oli.cd_line_status__c = '400';
        oli.LAT_MX_CDLineStatusFrom__c = '540';
        
        update oli;
       
        oli.cd_line_status__c = '600';
        oli.LAT_MX_CDLineStatusFrom__c = '580';
        
        update oli; */
        
    }

      /*  static testMethod void unitTest3() {
        Utils.setMigrationDoneTest(true); 
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;
                    
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            Credit_line__c = 1000,
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
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
            LAT_StageName__C = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        try{insert opp;} catch(exception e){}
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        try{insert prod1;} catch(exception e){}

        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '4442',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '56662',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        try{insert prod2;} catch(exception e){}
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 10,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota;
        
        system.test.startTest();
        Utils.setMigrationDoneTest(true);         
        
        LAT_OpportunityLineItem__c oli1 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_CdLineStatus__c = '400',
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_Quota__c = quota.Id
        );
        
        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 20,
            LAT_AR_UOM__c = 'CAa',
            LAT_SkuText__c = '1001',
            LAT_Product__c = prod2.Id,
            LAT_UnitPrice__c = 11,
            LAT_CdLineStatus__c = '400',
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_Quota__c = quota.Id
        );
                
        insert new List<LAT_OpportunityLineItem__c>{oli1,oli2};

        oli2.LAT_UnitPrice__c = 25;
        update oli2;


        system.test.stopTest();              
        
        /*
        oli.cd_line_status__c = '400';
        oli.LAT_MX_CDLineStatusFrom__c = '540';
        
        update oli;
       
        oli.cd_line_status__c = '600';
        oli.LAT_MX_CDLineStatusFrom__c = '580';
        
        update oli; 
        
    }*/
}