/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:28/01/2013    *
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 14/11/2016
*
********************************************************************************/

@istest(seeAllDAta=false)

public class LAT_VFC05_OppProductCustomExtension_TEST{

    static testMethod void myUnitTest() { 
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
        
        //Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 
        id standardPB = Test.getStandardPricebookId();
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB, 
            IsActive = true,
            UseStandardPrice = false
        );
        insert new List<PricebookEntry>{pbe3};
        
        test.startTest();
        Utils.setMigrationDoneTest(false);   
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        LAT_VFC05_OppProductCustomExtension cl = new LAT_VFC05_OppProductCustomExtension(sc);
        test.stopTest();   
    }

        static testMethod void myUnitTest2() { 
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
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        insert prod1;
        
        test.startTest();
        Utils.setMigrationDoneTest(true);   
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
        insert oli;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        LAT2_VFC05_OppProductCustomExtension cl = new LAT2_VFC05_OppProductCustomExtension(sc);
        test.stopTest();   
    }
}