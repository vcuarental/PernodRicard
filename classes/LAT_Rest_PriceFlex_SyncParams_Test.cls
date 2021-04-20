@isTest
private class LAT_Rest_PriceFlex_SyncParams_Test {
	@testSetup
	public static void setup(){
		LAT_WS_CustomerHandlerInterface_Test.testSetup();
		LAT_IMM_Operations__c op = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='initialSyncBalance', Service_Name_Header__c='IMM', Name = 'initialSyncBalance', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		LAT_IMM_Operations__c op1 = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='initialSyncParams', Service_Name_Header__c='IMM', Name = 'initialSyncParams', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		LAT_IMM_Operations__c op2 = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='AddTransaction', Service_Name_Header__c='IMM', Name = 'AddTransaction', Http_operation__c='POST', x_Api_key__c='FzH%pH32dyPU*F3B');
		List<LAT_GeneralConfig__c>  generalConfigs= new List<LAT_GeneralConfig__c> ();
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'BOXES_PER_PALLET_DEFAULT',
                              LAT_Value__c = '10'));
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'PERCENT_FREIGHT_DEFAULT',
                              LAT_Value__c = '10'));
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'IMM_LOG_NRO',
                              LAT_Value__c = '10'));
        insert generalConfigs;
		insert new List<LAT_IMM_Operations__c>{op,op1,op2};
		User vendas = [SELECT Id FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true LIMIT 1];
		System.runAs(vendas){
			Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
                CNPJ__c = '91370573000162',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'Prospect_ARG',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                Sub_Channel__c = 'Delicatessen',
                AddressLine1_AR__c= 'test',
                Shipping_Neighbourhood__c = 'test',
                Revenue_Neighbourhood__c = 'test',
                Billing_Neighbourhood__c ='test',
                Shipping_Country__c ='test',
                Revenue_Country__c ='test',
                Billing_Country__c ='test',
                Status__c = 'Novo cadastro',
                Client_code_An8__c = '1111',
				Client_country_An8__c = '1-1111',
				CurrencyISOCode = 'BRL'
            );
            
            //insert acc;
            insert acc;//}catch(Exception e){
		}
		
	}

	@isTest static void test_method_one() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        Test.startTest();
        insert opp;
        LAT_ScheduleC__c sche = new LAT_ScheduleC__c();
        sche.ExternalId__c = 'AAA';
        sche.Key__c = 'BBB';
        sche.Active__c = true;
        sche.KeyBrand__c = theKeyBrand().id;
        insert sche;
        LAT_Product__c prod1 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-444', LAT_IsRefactorProduct__c = 'Y', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-443', LAT_IsRefactorProduct__c = 'Y', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};

        
        
        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c(LAT_OriginalNisAmount__c = 10, LAT_IsFlex__c = true, LAT_Product__c = prod1.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74');
        insert oli;
        oli = [SELECT Id, LAT_IsFlex__c, LAT_FlexAmount__c, LAT_OriginalFlexAmount__c, LAT_NisAmount__c, LAT_OriginalNisAmount__c, LAT_Sku__c, 
                                                LAT_Product__r.LAT_Scheduler__c, LAT_IdIMM__c,LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.Key__c,
    											LAT_Opportunity__r.LAT_Account__r.Client_code_an8__c, LAT_Opportunity__r.LAT_Account__r.Regional__r.CodDefUsuario__c,
    											LAT_Opportunity__r.LAT_Account__r.LAT_Account__r.LAT_JDEZone__c, LAT_CdLineStatus__c, LAT_AR_Discount__c FROM LAT_OpportunityLineItem__c LIMIT 1];
        LAT_Rest_PriceFlex_SyncParams.addTransactionBulk(oli, 1000);
        LAT_Rest_PriceFlex_SyncParams.addTransaction(oli, 1000);
        LAT_Rest_PriceFlex_SyncParams.addTransactionBulk(oli, 1000);
        LAT_IMM_Logs__c log = new LAT_IMM_Logs__c();
		insert log;
		log.LAT_OpportunityLineItem__c = oli.Id;
		update log;
        Test.stopTest();

	}
	
	@isTest static void test_method_two() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        Test.startTest();
        insert opp;
        LAT_ScheduleC__c sche = new LAT_ScheduleC__c();
        sche.ExternalId__c = 'AAA';
        sche.Key__c = 'BBB';
        sche.Active__c = true;
        sche.KeyBrand__c = theKeyBrand().id;
        insert sche;
        
        LAT_Product__c prod1 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-444', LAT_IsRefactorProduct__c = 'Y', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-443', LAT_IsRefactorProduct__c = 'Y', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};

        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
        listOli.add(new LAT_OpportunityLineItem__c(LAT_NisAmount__c = 11, LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = -10, LAT_AR_Discount__c=-1, LAT_IsFlex__c = true, LAT_Product__c = prod1.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));
        listOli.add(new LAT_OpportunityLineItem__c(LAT_NisAmount__c = 11,LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = 10, LAT_AR_Discount__c=1, LAT_IsFlex__c = true, LAT_Product__c = prod2.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));

        insert listOli;

        LAT_Rest_PriceFlex_SyncParams.processFlexOpportunity(opp.Id);
        Test.stopTest();
	}
    @isTest static void test_method_two_B() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        Test.startTest();
        insert opp;
        LAT_ScheduleC__c sche = new LAT_ScheduleC__c();
        sche.ExternalId__c = 'AAA';
        sche.Key__c = 'BBB';
        sche.Active__c = true;
        sche.KeyBrand__c = theKeyBrand().id;
        insert sche;
        
        LAT_Product__c prod1 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-444', LAT_IsRefactorProduct__c = 'Y', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-443', LAT_IsRefactorProduct__c = 'Y', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};

        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
        listOli.add(new LAT_OpportunityLineItem__c(LAT_NisAmount__c = 11,LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = 10, LAT_AR_Discount__c=1, LAT_IsFlex__c = true, LAT_Product__c = prod2.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));
        listOli.add(new LAT_OpportunityLineItem__c(LAT_NisAmount__c = 11, LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = -10, LAT_AR_Discount__c=-1, LAT_IsFlex__c = true, LAT_Product__c = prod1.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));
        
        insert listOli;

        LAT_Rest_PriceFlex_SyncParams.processFlexOpportunity(opp.Id);
        Test.stopTest();
    }
	
	@isTest static void test_method_three() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        Test.startTest();
        insert opp;
        LAT_ScheduleC__c sche = new LAT_ScheduleC__c();
        sche.ExternalId__c = 'AAA';
        sche.Key__c = 'BBB';
        sche.Active__c = true;
        sche.KeyBrand__c = theKeyBrand().id;
        insert sche;

        LAT_Product__c prod1 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-444', LAT_IsRefactorProduct__c = 'Y', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-443', LAT_IsRefactorProduct__c = 'Y', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};

        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();        
        listOli.add(new LAT_OpportunityLineItem__c(LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = 10, LAT_AR_Discount__c=1, LAT_IsFlex__c = true, LAT_Product__c = prod2.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));
        listOli.add(new LAT_OpportunityLineItem__c(LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = -10, LAT_AR_Discount__c=-1, LAT_IsFlex__c = true, LAT_Product__c = prod1.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));

        insert listOli;

        RestRequest req = new RestRequest();
        req.params.put('executiveCode','executiveCode');
        req.params.put('method','initialSyncParams');

        RestContext.request = req;
        RestContext.response = new RestResponse();
        try{
        LAT_Rest_PriceFlex_SyncParams.doGet();
        }catch (Exception e){}
        LAT_Rest_PriceFlex_SyncParams.bodyTest = '333';
        LAT_Rest_PriceFlex_SyncParams.mockResponse();
        String a = LAT_Rest_PriceFlex_SyncParams.bodyTest;
        Test.stopTest();
	}
    
    @isTest static void test_method_four() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        Test.startTest();
        insert opp;
        LAT_ScheduleC__c sche = new LAT_ScheduleC__c();
        sche.ExternalId__c = 'AAA';
        sche.Key__c = 'BBB';
        sche.Active__c = true;
        sche.KeyBrand__c = theKeyBrand().id;
        insert sche;

        LAT_Product__c prod1 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-444', LAT_IsRefactorProduct__c = 'Y', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        LAT_Product__c prod2 = new LAT_Product__c(LAT_ScheduleC__c = sche.Id, Name = 'TestProd2', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '1-443', LAT_IsRefactorProduct__c = 'Y', LAT_Sku__c = '5667', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert new List<LAT_Product__c>{prod1, prod2};

        List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
        listOli.add(new LAT_OpportunityLineItem__c(LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = -10, LAT_AR_Discount__c=-1, LAT_IsFlex__c = true, LAT_FlexAmount__c = 100, LAT_Product__c = prod1.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));
        listOli.add(new LAT_OpportunityLineItem__c(LAT_OriginalNisAmount__c = 10, LAT_OriginalFlexAmount__c = 10, LAT_AR_Discount__c=1, LAT_FlexAmount__c = 100, LAT_IsFlex__c = true, LAT_Product__c = prod2.Id, LAT_Remover__c = false, LAT_Quantity__c = 200, LAT_AR_UOM__c = 'CA', LAT_SkuText__c = '100', LAT_UnitPrice__c = 10, LAT_Opportunity__c = opp.Id, LAT_MX_KAMPromisedDate__c = date.today(), LAT_StatusDescription__c = 'Faturado - test', LAT_FormatField__c = 'Preço Base - Cond. Pagto com ICMS|1|133,33|1933,12|15464,96#Desconto PRB|1|-71,81|-1041,18|-8329,43#Valor NF PRB|1|61,52|891,94|7135,53#Desconto Faseamento|1|0,00|0,00|0,00#Desconto FOB|1|0,00|0,00|0,00#PIS|1|0,00|0,00|0,00#COFINS|1|0,00|0,00|0,00#Valor Mercadoria|1|61,52|891,94|7135,53#IPI|1|0,00|0,00|0,00#Valor Mercadoria + IPI|1|61,52|891,94|7135,53#Substitução Tributaria|1|8,75|126,90|1015,2#Valor Total NF|1|70,27|1018,84|8150,74'));

        insert listOli;

        RestRequest req = new RestRequest();
        req.params.put('executiveCode','executiveCode');
        req.params.put('method','initialSyncParams');

        RestContext.request = req;
        RestContext.response = new RestResponse();
        try{
        LAT_Rest_PriceFlex_SyncParams.processRejectedFlexOpportunity(opp.Id);
        }catch (Exception e){}

        Test.stopTest();
    }
    
     public static LAT_KeyBrand__c theKeyBrand(){
        LAT_KeyBrand__c kb = new LAT_KeyBrand__c();
        kb.ExternalId__c = 'AAA';
        kb.Key__c = 'BBB';
        kb.Active__c = true;
        insert kb;
        return kb;
    }
}