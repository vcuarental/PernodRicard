/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:10/12/2013    *
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 10/11/2016
*
********************************************************************************/


@istest
public with sharing class LAT_MX_AvailableCreditLimit_TEST{

    static testMethod void unitTest1(){
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade'),
            credit_line__c = 100000,
            Client_code_AN8__c = '100'
        );
        insert acc;
        
        test.startTest();
        Utils.setMigrationDoneTest(false);        
        Titulos__c titulo = new Titulos__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'LAT_MX_TEA_Standard'),
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            valorSaldo__c = 10
        );
        try{insert titulo;}catch(Exception e){}
                
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
        try{insert opp;}catch(Exception e){}
        test.stopTest();
        /*
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
        
           */
    
    }

    static testMethod void unitTest2(){
        Utils.setMigrationDoneTest(true);    
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade'),
            credit_line__c = 100000,
            Client_code_AN8__c = '100'
        );
        insert acc;
        
        test.startTest();
        Utils.setMigrationDoneTest(true);        
        Titulos__c titulo = new Titulos__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'LAT_MX_TEA_Standard'),
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            valorSaldo__c = 10
        );
        try{insert titulo;}catch(Exception e){}
                
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
        try{insert opp;}catch(Exception e){}

        LAT_MX_AvailableCreditLimit.isForCC();
        test.stopTest();
        /*
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
        
           */
    
    }
  
}