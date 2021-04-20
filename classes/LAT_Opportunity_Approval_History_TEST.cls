@isTest
public class LAT_Opportunity_Approval_History_TEST{

    static testMethod void UnitTest1(){
        Utils.setMigrationDoneTest(true);
        
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR'));
        LAT_Product__c prod2 = new LAT_Product__c(Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '443', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR'));
        insert new List<LAT_Product__c>{prod1, prod2};

        User u = [select id, name from user where isactive = true and profile.name = 'LAT_AR2_Vendedor' limit 1];

        Test.startTest(); 
        System.runas(u) {

            Account acc = new Account(Name = 'TEST', LAT_BR_RegionalClientOnPremise__c = 'ON TRADE NE', /* Payment_Condition__c = udc.id,*/AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Phone = '+54 11 1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '30641670223', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'));
            insert acc;
            acc.Client_code_AN8__c = '100';
            update acc;

            LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_IsAdmin__c = true, LAT_NROrderJDE__c='123923', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Pedido con descuento en aprobación', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'OPP_1_NewOrder_ARG'));
        
            insert opp;

            List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
            LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(LAT_AR_SentToApproveDiscount__c = true, LAT_Remover__c = false,LAT_Quantity__c = 5, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100',  LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
            
            insert oli;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(opp.id);
            Approval.ProcessResult result = Approval.process(req1);

            LAT_Opportunity_Approval_History cont = new LAT_Opportunity_Approval_History();

            cont.relatedRecordId = opp.id;
            cont.getAllApprovalStep();
        }
                        
        Test.stopTest();
   
    }

}