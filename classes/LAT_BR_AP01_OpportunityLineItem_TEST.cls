/******************************************************************************************
 *   Company:Valuenet    Developers: Romero Nicolas Javier                Date:11/12/2013 *
 ******************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

@isTest(seeAllData=False)
public class LAT_BR_AP01_OpportunityLineItem_TEST{
    
    @testSetup static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');

        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(
            name = 'LAT_ACCOUNT_VERIFICATION_QUERY',
            lat_value__c = 'SELECT Id, Name FROM Account LIMIT 1');
 
        LAT_GeneralConfig__c cfg3 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_StatusToCheck',
            lat_value__c = 'Novo Pedido');

        LAT_GeneralConfig__c cfg4 = new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_OBJECTS',
                    LAT_Value__c = '\'Account\',\'LAT_Contract2__c\'');
        
        insert new List<LAT_GeneralConfig__c> {cfg1, cfg2, cfg3, cfg4 };
    }



    static testMethod void UnitTest2(){
        
        Utils.setMigrationDoneTest(true);
        Account acc = new Account(Client_code_AN8__c = '100', Name = 'TEST', AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Phone = '11 1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '51987528000137', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'));
        insert acc;
        //update acc;
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-444', LAT_IsRefactorProduct__c = 'Y', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-443', LAT_IsRefactorProduct__c = 'Y', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};

        LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        LAT_Opportunity__c opp2 = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='173123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        LAT_Opportunity__c opp3 = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='123129', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));       
        Test.startTest();
        insert new List<LAT_Opportunity__c>{opp, opp2, opp3};
        
       
        
        
        
        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_RawLinePriceComponents__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
        listOli.add(oli);
        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(LAT_Remover__c = false, LAT_Quantity__c = 200,LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp2.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Cancelado - test');
        listOli.add(oli2);
        LAT_BR_AP01_OpportunityLineItem.decodeCompositionPrice(listOli);

        map<id, LAT_OpportunityLineItem__c> mapOlis = new map<id, LAT_OpportunityLineItem__c>();
        for(LAT_OpportunityLineItem__c oli5:listOli){
            mapOlis.put(oli5.Id,oli5);
        }

        insert listOli;

        LAT_OpportunityLineItem__c oli1 = listOli.get(0);
        oli1.LAT_StatusDescription__c = 'Aprovação Test';
        

        LAT_OpportunityLineItem__c oli3 = listOli.get(1);
        oli3.LAT_StatusDescription__c = 'Faturado Test';

        update new List<LAT_OpportunityLineItem__c> {oli1,oli3};
      //  LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(listOli, new List<OpportunityLineItem>(), new Map<Id,OpportunityLineItem>());
        LAT_BR_AP01_OpportunityLineItem.decodeCompositionPrice(listOli);
        //LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(listOli, null, null);
        Test.stopTest();
    }

        static testMethod void UnitTest2R(){
        
        Utils.setMigrationDoneTest(true);
        Account acc = new Account(Client_code_AN8__c = '100', Name = 'TEST', AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Phone = '11 1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '51987528000137', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'));
        insert acc;
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-444', LAT_IsRefactorProduct__c = 'Y', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-443', LAT_IsRefactorProduct__c = 'Y', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};
        LAT_IMM_Logs__c log = new LAT_IMM_Logs__c (LAT_IMM_Id__c = '14',LAT_uuid__c = '14' );
        insert log;
        //update acc;
        Test.startTest();
        LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        LAT_Opportunity__c opp2 = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='173123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        LAT_Opportunity__c opp3 = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='123129', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));       
        insert new List<LAT_Opportunity__c>{opp, opp2, opp3};
        
        
        
        
        
        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(LAT_IdIMM__c='14', LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74', LAT_RawLinePriceComponents__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
        listOli.add(oli);
        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(LAT_IdIMM__c='15', LAT_Remover__c = false, LAT_Quantity__c = 200,LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp2.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Cancelado - test');
        listOli.add(oli2);
        LAT_BR_AP01_OpportunityLineItem.decodeCompositionPrice(listOli);

        map<id, LAT_OpportunityLineItem__c> mapOlis = new map<id, LAT_OpportunityLineItem__c>();
        for(LAT_OpportunityLineItem__c oli5:listOli){
            mapOlis.put(oli5.Id,oli5);
        }

        insert listOli;

        LAT_OpportunityLineItem__c oli1 = listOli.get(0);
        oli1.LAT_StatusDescription__c = 'Aprovação Test';
        oli1.LAT_NisAmount__c = 100;
          

        LAT_OpportunityLineItem__c oli3 = listOli.get(1);
        oli3.LAT_StatusDescription__c = 'Faturado Test';

        update new List<LAT_OpportunityLineItem__c> {oli1,oli3};
        LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(listOli, listOli, new Map<Id,LAT_OpportunityLineItem__c>());
        LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(new List<OpportunityLineItem>(), new List<OpportunityLineItem>(), new map<Id, OpportunityLineItem>());

        //LAT_BR_AP01_OpportunityLineItem.decodeCompositionPrice(listOli);
        //LAT_BR_AP01_OpportunityLineItem.updateStatusOpportunity(listOli, null, null);
        Test.stopTest();
    }

    static testMethod void UnitTest2B(){
        Utils.setMigrationDoneTest(true);
        Account acc = new Account(Client_code_AN8__c = '100', Name = 'TEST',/* Payment_Condition__c = udc.id,*/AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '30641670223', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'));
        insert acc;
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR'));
        LAT_Product__c prod2 = new LAT_Product__c(Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '443', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR'));
        insert new List<LAT_Product__c>{prod1, prod2};



        Test.startTest();
        Utils.setMigrationDoneTest(true);
        LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, 
            LAT_NROrderJDE__c='123923', 
            Name = 'test', 
            LAT_NRCustomerOrder__c = '100', 
            LAT_CloseDate__c = date.today(), 
            LAT_Type__c = 'Replenish', 
            LAT_DSMessage1__c = 'test', 
            LAT_DSMessage2__c = 'test', 
            LAT_StageName__c = 'Novo pedido', 
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'));
        LAT_Opportunity__c opp2 = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='128123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'));
        LAT_Opportunity__c opp3 = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='123723', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'));       
        insert new List<LAT_Opportunity__c>{opp, opp2, opp3};
        
        
        
        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,LAT_Quantity__c = 200, 
            LAT_AR_UOM__c = 'CA', 
            LAT_SkuText__c = '100',  
            LAT_UnitPrice__c = 10, 
            LAT_Opportunity__c = opp.Id, 
            LAT_MX_KAMPromisedDate__c = date.today(), 
            LAT_StatusDescription__c = 'Faturado - test', 
            LAT_RawLinePriceComponents__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74',
            LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
        insert oli;
        listOli.add(oli);
        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false, 
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA', 
            LAT_SkuText__c = '100', 
            LAT_UnitPrice__c = 10, 
            LAT_Opportunity__c = opp2.Id, 
            LAT_MX_KAMPromisedDate__c = date.today(), 
            LAT_StatusDescription__c = 'Cancelado - test');
        insert oli2;
        listOli.add(oli2);
        LAT_OpportunityLineItem__c oli3 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false, 
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA', 
            LAT_SkuText__c = '100', 
            LAT_UnitPrice__c = 10, 
            LAT_Opportunity__c = opp2.Id, 
            LAT_MX_KAMPromisedDate__c = date.today(), 
            LAT_StatusDescription__c = 'Back Order');
        //insert oli3;
        //listOli.add(oli3);

        update listOli;
        //insert listOli;
        
        LAT_AR_AP01_OpportunityLineItem.validateStatus( listOli, new Map<Id,LAT_OpportunityLineItem__c>());
        LAT_AR_AP01_OpportunityLineItem.existeItemEmBackOrder(listOli);
       // LAT_AR_AP01_OpportunityLineItem.updateStatusOpportunity(listOli,listOli,new Map<Id,OpportunityLineItem>());
       Test.stopTest();
    }
}