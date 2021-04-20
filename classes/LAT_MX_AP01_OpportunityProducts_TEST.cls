/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:04/12/2013    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 10/11/2016
*
********************************************************************************/

@istest(seeAllDAta=false)
public with sharing class LAT_MX_AP01_OpportunityProducts_TEST {

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
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
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

        Id pricebookId = Test.getStandardPricebookId();
        
        //Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 
        
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = pricebookId, 
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
              
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_Quota__c = quota.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),
            LAT_MX_CDLineStatusFrom__c = '540'
        );
        insert oli;

        oli.cd_line_status__c = '400';
        oli.LAT_MX_CDLineStatusFrom__c = '560';
        update oli;
        
        LAT_MX_AP01_OpportunityProducts.parseHelper('<table><tr><td>headerText</td></tr></table>', '<tr>', 1);

        system.test.stopTest();              
    }

    static testMethod void unitTest2() {
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
            LAT_DTDelivery__c = date.today(),
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );        
        insert opp;
                
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(name ='MX_IndexMarca_Notification_Users', LAT_Value__C = '1');
        insert cfg;
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@zimmic.com');
        insert cfg2;
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(name ='MX_DEFAULT_INDEX_MARGIN', LAT_Value__C = '2');
        insert cfg1;

        LAT_CHATTER_POST_BODY__c cpb = new LAT_CHATTER_POST_BODY__c();
        cpb.Name = 'LAT_MX_ProductoSinIndexMarca';
        cpb.Body__c = 'Tests';
        insert cpb;
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );        
        insert prod1;
        
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
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_C9Quantity__c = 100,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_MX_Quota__c = quota.Id,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today(),          
            LAT_MX_CDLineStatusFrom__c = '540'
        );        
        insert oli;

        oli.LAT_CdLineStatus__c = '400';
        update oli;
        
        system.test.stopTest();    
        /*
        oli.cd_line_status__c = '400';
        oli.LAT_MX_CDLineStatusFrom__c = '540';
        
        update oli;
       
        oli.cd_line_status__c = '600';
        oli.LAT_MX_CDLineStatusFrom__c = '580';
        
        update oli; */
    }
}