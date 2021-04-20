@isTest
private class LAT_AR_UpdateOppDiscountBatchTest {
	
	@isTest static void test_method_one() {
		Utils.setMigrationDoneTest(false);
         
        Account acc;
        
        acc = new Account(Name = 'TEST',/* Payment_Condition__c = udc.id,*/AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Phone = '11 1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '30641670223', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'));
        insert acc;
        acc.Client_code_AN8__c = '100';
        update acc;
        
 		Utils.setMigrationDoneTest(false);

        Opportunity opp = new Opportunity(AccountId = acc.Id, NR_order_JDE__c='123923', Name = 'test', NR_customer_order__c = '100', CloseDate = date.today(), Type = 'Replenish', DS_Message1__c = 'test', DS_Message2__c = 'test', StageName = 'Novo pedido', RecordTypeId = '012D00000007IXE');
        insert opp;
        
        Product2 prod1 = new Product2(Name = 'TestProd', IsActive = true, CD_Unit__c = 'CA', Internal_id__c = '444', QT_lead_time__c = 5, SKU__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'Standard_AR'));
        insert prod1;

        Id standardPB =  Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 12, Pricebook2Id = standardPB, IsActive =true, UseStandardPrice = false);
        insert pbe1;
       
        OpportunityLineItem oli = new OpportunityLineItem(Discount_AR__c = 2, Remover__c = false,Quantity = 200, UOM_AR__c = 'CA', LAT_SkuText__c = '100', PriceBookEntryId = pbe1.Id, UnitPrice = 10, OpportunityId = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), Descricao_do_status__c = 'Faturado - test', Campo_de_formatacao__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
        insert oli;
	 	Test.startTest();
 		Utils.setMigrationDoneTest(true);
	 	Profile p = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Vendedor' LIMIT 1];
	 	User u = new User();
        u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');  
	 	u.ProfileID = p.Id;
	 	insert u;
        LAT_Product__c LAT_prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR'));
        insert LAT_prod1;

	        LAT_Opportunity__c LAT_opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='123923', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = Date.valueOf('2016-01-01'), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido');
	       	insert LAT_opp;
	        
	        LAT_OpportunityLineItem__c LAT_oli = new LAT_OpportunityLineItem__c(LAT_Product__c = LAT_prod1.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100',  LAT_UnitPrice__c = 10, LAT_Opportunity__c = LAT_opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
	        insert LAT_oli;

	    LAT_opp.LAT_StageName__c = 'Pedido processado no JDE';
	    update LAT_opp;
	    Test.stopTest();
	    Set<String> testSet = new Set<String>();
	    testSet.add('012D00000007IXE');
		Database.executeBatch(new LAT_AR_UpdateOpportunityDiscountBatch(testSet, testSet),200 );


	}
	
}