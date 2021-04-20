/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:10/12/2013    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 10/11/2016
*
********************************************************************************/


@istest(seeAllDAta=false)
public with sharing class LAT_MX_AP01_Quota_TEST {

    static testMethod void unitTest() {
        try{
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        try{insert acc;} catch(exception e){}
        
        test.startTest();
        acc.Client_code_AN8__c = '100';        
        try{update acc;} catch(exception e){}
                
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
        try{insert opp;} catch(exception e){}
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );        
        try{insert prod1;} catch(exception e){}

        //Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        try{insert pricebook;} catch(exception e){}
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = pricebookId, 
            IsActive = true,
            UseStandardPrice = false
        );        
        try{insert pbe3;} catch(exception e){}
        
        LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            LAT_MX_ValidityUntil__c = date.today().addDays(3),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard')        
        );
        
        LAT_MX_QTA_Quota__c quota2 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_MX_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today().addDays(4),
            LAT_MX_ValidityUntil__c = date.today().addDays(10),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard')        
        );
        try{insert new List<LAT_MX_QTA_Quota__c>{quota,quota2};} catch(exception e){}
        
        Utils.setMigrationDoneTest(false);                
        OpportunityLineItem oli1 = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_Quota__c = quota.Id
        );
        /*
        OpportunityLineItem oli2 = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 20,
            UOM_AR__c = 'CAa',
            LAT_SkuText__c = '1001',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 11,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_Quota__c = quota.Id
        );   */             
            try{insert new List<OpportunityLineItem>{oli1};}catch (Exception e){}
        
        //quota.LAT_MX_Quota__c = 200;
        test.stopTest();        
        //try{update quota;} catch(exception e){} 
        } catch (Exception e){
test.stopTest();        
        }
         
    }

    static testMethod void unitTest2() {
        try{
        Utils.setMigrationDoneTest(true);   
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );        
        try{insert acc;} catch(exception e){}
        test.startTest();
        Utils.setMigrationDoneTest(true); 
        acc.Client_code_AN8__c = '100';        
        try{update acc;} catch(exception e){}
                
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
            LAT_MX_ValidityUntil__c = date.today().addDays(3),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard')        
        );
        
        LAT_MX_QTA_Quota__c quota2 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = acc.Id,
            LAT_Product__c = prod1.Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today().addDays(4),
            LAT_MX_ValidityUntil__c = date.today().addDays(10),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard')        
        );
        try{
            insert new List<LAT_MX_QTA_Quota__c>{quota,quota2};
        } catch(exception e){}
        
                       
        LAT_OpportunityLineItem__c oli1 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
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
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_Quota__c = quota.Id
        );
                
        insert new List<LAT_OpportunityLineItem__c>{oli1,oli2};
        
        quota.LAT_MX_Quota__c = 200;
        
        try{update quota;} catch(exception e){} 
        
         } catch (Exception e){

        }
        test.stopTest();             
    
    }
}