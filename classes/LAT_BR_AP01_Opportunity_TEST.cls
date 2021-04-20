/******************************************************************************************
 *   Company:Valuenet    Developers: Romero Nicolas Javier                Date:13/12/2013 *
 ******************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/


@isTest(seeAllData=False)
public class LAT_BR_AP01_Opportunity_TEST{

    static testMethod void UnitTest(){
        test.StartTest();
        Utils.setMigrationDoneTest(false);
        Account acc = new Account(Name = 'TEST', AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Phone = '11 1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '51987528000137', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'));
        insert acc;
        acc.Client_code_AN8__c = '100';
        update acc;
        
        List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity opp = new Opportunity(AccountId = acc.Id, NR_order_JDE__c='123123', Name = 'test', NR_customer_order__c = '100', CloseDate = date.today(), Type = 'Replenish', DS_Message1__c = 'test', DS_Message2__c = 'test', StageName = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade'));
        listOpp.add(opp);
        insert listOpp;
        
        Product2 prod1 = new Product2(Name = 'TestProd', IsActive = true, CD_Unit__c = 'CA', Internal_id__c = '444', QT_lead_time__c = 5, SKU__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard'));
        Product2 prod2 = new Product2(Name = 'TestProd2', IsActive = true, CD_Unit__c = 'CA', Internal_id__c = '443', SKU__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard'));
        insert new List<Product2>{prod1, prod2};

        test.StopTest();
        Id standardPB =  Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 12, Pricebook2Id = standardPB, IsActive =true, UseStandardPrice = false);
        insert pbe1;
        
        OpportunityLineItem oli = new OpportunityLineItem(Remover__c = false,Quantity = 200, UOM_AR__c = 'CA', LAT_SkuText__c = '100', PriceBookEntryId = pbe1.Id, UnitPrice = 10, OpportunityId = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), Descricao_do_status__c = 'Faturado - test');
        //OpportunityLineItem oli2 = new OpportunityLineItem(Remover__c = false, Quantity = 200,UOM_AR__c = 'CA', LAT_SkuText__c = '100', PriceBookEntryId = pbe1.Id, UnitPrice = 10, OpportunityId = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), Descricao_do_status__c = 'Cancelado - test');
        insert new List<OpportunityLineItem>{oli};
        
        delete listOpp;
        LAT_BR_AP01_Opportunity.updateStockCota(listOpp);
        LAT_BR_AP01_Opportunity.validateStatusDelete(listOpp);
        
    }

    static testMethod void UnitTest2(){
        test.StartTest();
        Utils.setMigrationDoneTest(true);
        Account acc = new Account(Name = 'TEST', AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Phone = '11 1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '51987528000137', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'));
        insert acc;
        acc.Client_code_AN8__c = '100';
        update acc;
        
        List<LAT_Opportunity__c> listOpp = new List<LAT_Opportunity__c>();
        LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='123123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        listOpp.add(opp);
        insert listOpp;
        
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '443', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};

        test.StopTest();
        
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(LAT_Product__c = prod1.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test');
        //OpportunityLineItem oli2 = new OpportunityLineItem(Remover__c = false, Quantity = 200,UOM_AR__c = 'CA', LAT_SkuText__c = '100', PriceBookEntryId = pbe1.Id, UnitPrice = 10, OpportunityId = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), Descricao_do_status__c = 'Cancelado - test');
        insert new List<LAT_OpportunityLineItem__c>{oli};
        
        LAT_BR_AP01_Opportunity.checkAllowWebCRM(listOpp);
        LAT_BR_AP01_Opportunity.setMobileOrder(listOpp); 
        
        delete listOpp;
        LAT_BR_AP01_Opportunity.updateStockCota(listOpp);
        LAT_BR_AP01_Opportunity.validateStatusDelete(listOpp);
        
    }
}