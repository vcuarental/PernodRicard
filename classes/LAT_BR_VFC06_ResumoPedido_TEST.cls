/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:30/12/2013    *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

@isTest(seeAllData=False)
public with sharing class LAT_BR_VFC06_ResumoPedido_TEST {

    static testMethod void unitTest() {
        Utils.setMigrationDoneTest(false);
        Account acc = new Account(
            CNPJ__c = '54651716001150',
            Channel__c = 'On Trade',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'),
            Name = 'testAccount',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Client_code_AN8__c = '16--5-77',
            Billing_Country__c ='test',
            LAT_BR_RegionalClientOnPremise__c = 'REG NE',
            Rating_segmentation_targert_market__c = 'Leading'
        );
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        update acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id, 
            NR_order_JDE__c='123123', 
            Name = 'test', 
            NR_customer_order__c = '100', 
            CloseDate = date.today(), 
            Type = 'Replenish', 
            DS_Message1__c = 'test', 
            DS_Message2__c = 'test', 
            StageName = 'Novo pedido', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade')
        );
        insert opp;
        /*
        Product2 prod1 = new Product2(
            Name = 'TestProd', 
            IsActive = true, 
            CD_Unit__c = 'CA', 
            Internal_id__c = '444', 
            QT_lead_time__c = 5, 
            SKU__c = '5666', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard')
        );
        Product2 prod2 = new Product2(
            Name = 'TestProd2', 
            IsActive = true, 
            CD_Unit__c = 'CA', 
            Internal_id__c = '443', 
            SKU__c = '5667', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard')
        );
        insert new List<Product2>{prod1, prod2};

        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 
        
        PricebookEntry pbe1 = new PricebookEntry(
            Product2Id = prod1.Id, 
            UnitPrice = 12, 
            Pricebook2Id = standardPB.Id, 
            IsActive = true, 
            UseStandardPrice = false
        );
        insert pbe1;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200, 
            UOM_AR__c = 'CA', 
            LAT_SkuText__c = '100', 
            PriceBookEntryId = pbe1.Id, 
            UnitPrice = 10, 
            OpportunityId = opp.Id, 
            LAT_MX_KAMPromisedDate__c = date.today(), 
            Descricao_do_status__c = 'Faturado - test'
        );
        insert oli;*/

        ApexPages.currentPage().getParameters().put('oppId', opp.Id); 
        ApexPages.currentPage().getParameters().put('accId', acc.Id); 
        ApexPages.currentPage().getParameters().put('priceSim', '1');
        
        system.test.startTest();
        
        LAT_BR_VFC06_ResumoPedido controller = new LAT_BR_VFC06_ResumoPedido();

        controller.renderTable();
        
        ApexPages.currentPage().getParameters().put('oppId', ''); 
        ApexPages.currentPage().getParameters().put('priceSim', '0');
        
        LAT_BR_VFC06_ResumoPedido controller1 = new LAT_BR_VFC06_ResumoPedido();
        
        ApexPages.currentPage().getParameters().put('oppId', 'test'); 
        
        LAT_BR_VFC06_ResumoPedido controller2 = new LAT_BR_VFC06_ResumoPedido();
        
        system.test.stopTest();
    }

    static testMethod void unitTest2() {
        Utils.setMigrationDoneTest(true);
        Account acc = new Account(
            CNPJ__c = '54651716001150',
            Channel__c = 'On Trade',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'),
            Name = 'testAccount',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Client_code_AN8__c = '16--5-77',
            Billing_Country__c ='test',
            LAT_BR_RegionalClientOnPremise__c = 'REG NE',
            Rating_segmentation_targert_market__c = 'Leading'
        );
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        update acc;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id, 
            LAT_NROrderJDE__c='123123', 
            Name = 'test', 
            LAT_NRCustomerOrder__c = '100', 
            LAT_CloseDate__c = date.today(), 
            LAT_Type__c = 'Replenish', 
            LAT_DSMessage1__c = 'test', 
            LAT_DSMessage2__c = 'test', 
            LAT_StageName__c = 'Novo pedido', 
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade')
        );
        insert opp;
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd', 
            LAT_IsActive__c = true, 
            LAT_CDUnit__c = 'CA', 
            LAT_ExternalId__c = '444', 
            LAT_QTLeadTime__c = 5, 
            LAT_Sku__c = '5666', 
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard')
        );
        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2', 
            LAT_IsActive__c = true, 
            LAT_CDUnit__c = 'CA', 
            LAT_ExternalId__c = '443', 
            LAT_Sku__c = '5667', 
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard')
        );
        insert new List<LAT_Product__c>{prod1, prod2};

        
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200, 
            LAT_AR_UOM__c = 'CA', 
            LAT_SkuText__c = '100', 
            LAT_UnitPrice__c = 10, 
            LAT_Product__c = prod1.Id,
            LAT_Opportunity__c = opp.Id, 
            LAT_MX_KAMPromisedDate__c = date.today(), 
            LAT_StatusDescription__c = 'Faturado - test'
        );
        insert oli;
        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200, 
            LAT_AR_UOM__c = 'CA', 
            LAT_SkuText__c = '100', 
            LAT_UnitPrice__c = 10,
            LAT_Product__c = prod2.Id, 
            LAT_Opportunity__c = opp.Id, 
            LAT_MX_KAMPromisedDate__c = date.today(), 
            LAT_StatusDescription__c = 'Faturado - test'
        );
        insert oli2;

        ApexPages.currentPage().getParameters().put('oppId', opp.Id); 
        ApexPages.currentPage().getParameters().put('accId', acc.Id); 
        ApexPages.currentPage().getParameters().put('priceSim', '1');
        
        system.test.startTest();
        
        LAT_BR_VFC06_ResumoPedido controller = new LAT_BR_VFC06_ResumoPedido();
        controller.renderTable();
        
        ApexPages.currentPage().getParameters().put('oppId', ''); 
        ApexPages.currentPage().getParameters().put('priceSim', '0');
        
        LAT_BR_VFC06_ResumoPedido controller1 = new LAT_BR_VFC06_ResumoPedido();
        
        ApexPages.currentPage().getParameters().put('oppId', 'test'); 
        
        LAT_BR_VFC06_ResumoPedido controller2 = new LAT_BR_VFC06_ResumoPedido();
        
        system.test.stopTest();
    }
}