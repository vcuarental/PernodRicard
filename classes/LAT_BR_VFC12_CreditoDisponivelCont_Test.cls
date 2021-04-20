@isTest(seeAllData=false)

private class LAT_BR_VFC12_CreditoDisponivelCont_Test {
	
	static testMethod  void test_method_one() {
		
		Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert acc;
        Test.startTest();

		LAT_Utils.testOn = true;
		// Implement test code
	 	LAT_ACCOUNT__c latAcc = [SELECT Id,LAT_Cred_RequestDate__c,LAT_Cred_UpdatedDate__c,LAT_Accountid__c FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: acc.Id limit 1];
		
		Opportunity opp = LAT_Opportunity_TestFactory.getCRMOppty(acc.id);
		insert opp;

		Product2 prod1 = new Product2(Name = 'TestProd', IsActive = true, CD_Unit__c = 'CA', Internal_id__c = '444', QT_lead_time__c = 5, SKU__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'Standard_AR'));
        Product2 prod2 = new Product2(Name = 'TestProd2', IsActive = true, CD_Unit__c = 'CA', Internal_id__c = '443', SKU__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'Standard_AR'));
        insert new List<Product2>{prod1, prod2};
        
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 12, Pricebook2Id = Test.getStandardPricebookId(), IsActive =true, UseStandardPrice = false);
        insert pbe1;


	        List<OpportunityLineItem> listOli = new List<OpportunityLineItem>();
	        OpportunityLineItem oli = new OpportunityLineItem(Remover__c = false,Quantity = 200, UOM_AR__c = 'CA', LAT_SkuText__c = '100', PriceBookEntryId = pbe1.Id, UnitPrice = 10, OpportunityId = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), Descricao_do_status__c = 'Faturado - test', Campo_de_formatacao__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
	        listOli.add(oli);
	       
	        insert listOli;

			opp.StageName = 'Totally billed';
			opp.Integracao__c = true;
			update opp;

			opp.StageName = 'Partially billed';
			opp.Integracao__c = true;
			update opp;
		List<Opportunity> listaOpp = new List<Opportunity>{opp};
		Test.stopTest();

		LAT_Utils.testOn = true;
		Apexpages.currentPage().getParameters().put('accId',latAcc.Id);
		LAT_BR_VFC12_CreditoDisponivelController cont = new LAT_BR_VFC12_CreditoDisponivelController();
		cont.acc = latAcc;
		LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper inerclass = new LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper();

		LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper inerclass2 = new LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper(100000.00,9000.00,10.00,10000.00,10.00 );
		inerclass2.getLimiteDisponivel();
		//LAT_BR_VFC12_CreditoDisponivelController.requestCreditoDisponible(latAcc);
		//LAT_BR_VFC12_CreditoDisponivelController.setInitCreditoDisponible(latAcc.id);
		//LAT_BR_VFC12_CreditoDisponivelController.updateCreditoDisponible(latAcc);
		LAT_BR_VFC12_CreditoDisponivelController.validateCreditoDisponible(opp.Id,acc.Id);
		//LAT_BR_VFC12_CreditoDisponivelController.updateRequestDate(listaOpp);
		cont.actionCreditoDisponible();
		cont.checkLastUpdated(latAcc,true);
		cont.clone();
		cont.getformatDate();
		cont.updateValores();
		//LAT_BR_VFC12_CreditoDisponivelController.validateCreditoDisponible(opp.Id,acc.Id);

	}
	
	static testMethod  void test_method_two() {
		Utils.setMigrationDoneTest(true);
		
		Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert acc;

		Test.startTest();
		LAT_Utils.testOn = true;
		// Implement test code

        LAT_ACCOUNT__c latAcc = [SELECT Id,LAT_Cred_RequestDate__c,LAT_Cred_UpdatedDate__c,LAT_Accountid__c FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c =: acc.Id limit 1];
		
		
		LAT_Opportunity__c opp = LAT_Opportunity_TestFactory.LAT_getCRMOppty(acc.id);
		insert opp;

		LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalId__c = '444', LAT_QTLeadTime__c = 5, LAT_SKU__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR'));
        LAT_Product__c prod2 = new LAT_Product__c(Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalId__c = '443', LAT_SKU__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR'));
        insert new List<LAT_Product__c>{prod1, prod2};
        
        //PricebookEntry pbe1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 12, Pricebook2Id = Test.getStandardPricebookId(), IsActive =true, UseStandardPrice = false);
        //insert pbe1;

        
		Utils.setMigrationDoneTest(true);
	        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
	        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(LAT_Remover__c = false,
	        	LAT_Quantity__c = 200, 
	        	LAT_AR_UOM__c = 'CA', 
	        	LAT_SkuText__c = '100', 
	        	LAT_Product__c = prod1.Id, 
	        	LAT_UnitPrice__c = 10, 
	        	LAT_Opportunity__c = opp.Id, 
	        	LAT_MX_KAMPromisedDate__c = date.today(), 
	        	LAT_StatusDescription__c = 'Faturado - test', 
	        	LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
	        listOli.add(oli);
	       
	        insert listOli;

			opp.LAT_StageName__c = 'Totally billed';
			opp.LAT_Integration__c = true;
			update opp;

			opp.LAT_StageName__c = 'Partially billed';
			opp.LAT_Integration__c = true;
			update opp;
		List<LAT_Opportunity__c> listaOpp = new List<LAT_Opportunity__c>{opp};
		Test.stopTest();
		LAT_Utils.testOn = true;
		Apexpages.currentPage().getParameters().put('accId',latAcc.Id);
		LAT_BR_VFC12_CreditoDisponivelController cont = new LAT_BR_VFC12_CreditoDisponivelController();
		cont.acc = latAcc;
		LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper inerclass = new LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper();

		LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper inerclass2 = new LAT_BR_VFC12_CreditoDisponivelController.limiteCreditoWrapper(100000.00,9000.00,10.00,10000.00,10.00 );
		inerclass2.getLimiteDisponivel();
		//LAT_BR_VFC12_CreditoDisponivelController.requestCreditoDisponible(latAcc);
		//LAT_BR_VFC12_CreditoDisponivelController.setInitCreditoDisponible(latAcc.id);
		//LAT_BR_VFC12_CreditoDisponivelController.updateCreditoDisponible(latAcc);
		LAT_BR_VFC12_CreditoDisponivelController.validateCreditoDisponible(opp.Id,acc.Id);
		//LAT_BR_VFC12_CreditoDisponivelController.updateRequestDate(listaOpp);

		cont.actionCreditoDisponible();
		cont.checkLastUpdated(latAcc,true);
		cont.clone();
		cont.getformatDate();
		cont.updateValores();
		//LAT_BR_VFC12_CreditoDisponivelController.validateCreditoDisponible(opp.Id,acc.Id);

	}
	
}