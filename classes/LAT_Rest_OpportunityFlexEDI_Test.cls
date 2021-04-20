@isTest
public class LAT_Rest_OpportunityFlexEDI_Test {
	
	@testSetup
	public static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
		LAT_WS_CustomerHandlerInterface_Test.testSetup();
        LAT_ContractPaymentsHandlerInt_Test.createCreds();
		LAT_IMM_Operations__c op = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='initialSyncBalance', Service_Name_Header__c='IMM', Name = 'initialSyncBalance', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		LAT_IMM_Operations__c op1 = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='initialSyncParams', Service_Name_Header__c='IMM', Name = 'initialSyncParams', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		LAT_IMM_Operations__c op2 = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='AddTransaction', Service_Name_Header__c='IMM', Name = 'AddTransaction', Http_operation__c='POST', x_Api_key__c='FzH%pH32dyPU*F3B');
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
		List<LAT_GeneralConfig__c>  generalConfigs= new List<LAT_GeneralConfig__c> ();
		generalConfigs.add(new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com'));
            
		generalConfigs.add(new LAT_GeneralConfig__c(
            name = 'LAT_BR_FlexEDI_Enabled',
            lat_value__c = 'true'));

        generalConfigs.add(new LAT_GeneralConfig__c(
            name = 'LAT_ACCOUNT_VERIFICATION_QUERY',
            lat_value__c = 'SELECT Id, Name FROM Account LIMIT 1'));
 
        generalConfigs.add( new LAT_GeneralConfig__c(
            name = 'OPP_Verification_StatusToCheck',
            lat_value__c = 'Novo Pedido'));

        generalConfigs.add(new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_OBJECTS',
                    LAT_Value__c = '\'Account\',\'LAT_Contract2__c\''));
        generalConfigs.add(new LAT_GeneralConfig__c(
                      Name = 'IMM_LOG_NRO',
                    LAT_Value__c = '100'));
        
        insert generalConfigs;
	}

	@isTest
	public static void test_Method_1(){
		
		Account acc = [SELECT Id, OwnerId, Client_code_An8__c FROM Account LIMIT 1];
		User vendas = [SELECT Id FROM User WHERE id = :acc.OwnerId];
		LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;

        
        User u = new User();
        u.Id = acc.OwnerId;        
        System.runAs(u){
            LAT_OpportunityHandlerJSON pedidoJSON = createPedidoJSON(acc, prod1, paymentCondition, false);
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            LAT_Rest_OpportunityFlex.acc = acc;	
            Map<Id, LAT_Product__c> mapProds = new Map<Id, LAT_Product__c>();
            mapProds.put(prod1.Id, prod1);
            LAT_Rest_OpportunityFlex.mapProdById = mapProds;
            Map<String, Decimal> mapPriceBySku = new Map<String, Decimal>();
            mapPriceBySku.put(prod1.Id, 100);
            LAT_Rest_OpportunityFlex.mapPriceBySku = mapPriceBySku;
        

			Test.startTest();
            LAT_Opportunity__c opp = LAT_Rest_OpportunityFlex.insertOpportunity(pedidoJSON);
            
            pedidoJSON.Header.ID = opp.Id;
            List<LAT_OpportunityLineItem__c> lines = [SELECT Id FROM LAT_OpportunityLineItem__c LIMIT 1];
            pedidoJSON.detail[0].Id = lines[0].Id;

            req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
            RestContext.request = req;
            RestContext.response = res;
            Map<String,String> mapa = new Map<String,String>();
        	mapa.put('ANY key', 'ANY value');
        	String mockbody = '[{ "regionCode": "3","brandCode": "ABT","brandDescription": "Absolut Regular", "executiveCode": "31C", "balanceAmount": 12000}]';
        	Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status',mockbody , mapa));	
            LAT_Rest_OpportunityFlex.acc = acc;	
			try{LAT_Rest_OpportunityFlexEDI.processPost();}catch(Exception e){}
            Test.stopTest();
        }
		

	}@isTest
	public static void test_Method_1B(){
		
		Account acc = [SELECT Id, OwnerId, Client_code_An8__c FROM Account LIMIT 1];
		User vendas = [SELECT Id FROM User WHERE id = :acc.OwnerId];
		LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;

        
        User u = new User();
        u.Id = acc.OwnerId;        
        System.runAs(u){
            LAT_OpportunityHandlerJSON pedidoJSON = createPedidoJSON(acc, prod1, paymentCondition, true);
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            LAT_Rest_OpportunityFlex.acc = acc;	
            Map<Id, LAT_Product__c> mapProds = new Map<Id, LAT_Product__c>();
            mapProds.put(prod1.Id, prod1);
            LAT_Rest_OpportunityFlex.mapProdById = mapProds;
            Map<String, Decimal> mapPriceBySku = new Map<String, Decimal>();
            mapPriceBySku.put(prod1.Id, 100);
            LAT_Rest_OpportunityFlex.mapPriceBySku = mapPriceBySku;
        

			Test.startTest();
            LAT_Opportunity__c opp = LAT_Rest_OpportunityFlex.insertOpportunity(pedidoJSON);
            
            pedidoJSON.Header.ID = opp.Id;
            List<LAT_OpportunityLineItem__c> lines = [SELECT Id FROM LAT_OpportunityLineItem__c LIMIT 1];
            pedidoJSON.detail[0].Id = lines[0].Id;
            pedidoJSON.detail[0].isOkEDI = false;

            req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
            RestContext.request = req;
            RestContext.response = res;
            Map<String,String> mapa = new Map<String,String>();
        	mapa.put('ANY key', 'ANY value');
        	String mockbody = '[{ "regionCode": "3","brandCode": "ABT","brandDescription": "Absolut Regular", "executiveCode": "31C", "balanceAmount": 12000}]';
        	Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status',mockbody , mapa));	
            LAT_Rest_OpportunityFlex.acc = acc;	
			try{LAT_Rest_OpportunityFlexEDI.processPost();}catch(Exception e){}
            Test.stopTest();
        }
		

	}
	/*
    @isTest
	public static void test_Method_2(){
		
		Account acc = [SELECT Id, OwnerId, Client_code_An8__c FROM Account LIMIT 1];
		User vendas = [SELECT Id FROM User WHERE id = :acc.OwnerId];
		LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;

        Test.startTest();
        
		
        LAT_OpportunityHandlerJSON pedidoJSON = createPedidoJSON(acc, prod1, paymentCondition);
        
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        
        LAT_Rest_OpportunityFlex.acc = acc;	
        Map<Id, LAT_Product__c> mapProds = new Map<Id, LAT_Product__c>();
        mapProds.put(prod1.Id, prod1);
        LAT_Rest_OpportunityFlex.mapProdById = mapProds;
        Map<String, Decimal> mapPriceBySku = new Map<String, Decimal>();
        mapPriceBySku.put(prod1.Id, 100);
        LAT_Rest_OpportunityFlex.mapPriceBySku = mapPriceBySku;
		LAT_Opportunity__c opp = LAT_Rest_OpportunityFlex.insertOpportunity(pedidoJSON);
		pedidoJSON.Header.ID = opp.Id;
        List<LAT_OpportunityLineItem__c> lines = [SELECT Id FROM LAT_OpportunityLineItem__c LIMIT 1];
        for(LAT_OpportunityLineItem__c oli : lines ){
            oli.LAT_OriginalFlexAmount__c = 10;
        }
        update lines;
        pedidoJSON.detail[0].Id = lines[0].Id;

        String mockbody = '[{ "regionCode": "3","brandCode": "ABT","brandDescription": "Absolut Regular", "executiveCode": "31C", "balanceAmount": 12000}]';

		req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
		RestContext.request = req;
		RestContext.response = res;
		Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');

        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status',mockbody , mapa));
        LAT_Rest_OpportunityFlex.shouldhaveException = true;
        try{LAT_Rest_OpportunityFlexEDI.rollbackChanges(opp.Id);}catch(Exception e){}
		
		Test.stopTest();

	}
*/
    @isTest
	public static void test_processOpportunity(){
		insert new CS001_JDEInterfaceCredentials__c(Name='Argentina', UserName__c = 'admin.Username', Country__c = '6', EndPoint_CustomerHandler__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerHandlerReq?WSDL',
				EndPoint_CustomerVerify__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerVerifyReq?WSDL', EndPoint_PriceCalculation__c = 'http://osbdev.pramericas.com/SFDC/Price/PriceCalculationReq?WSDL', Exec_new_Price_Calc__c = true,
				EndPoint_SalesOrderHandler__c = 'http://osbdev.pramericas.com/SFDC/SalesOrder/AsyncSalesOrderHandlerReq?WSDL', RemoteHostIP__c = '200.200.10.10', SystemUserID__c = 'cloud2b', EndPoint_BalanceCheck__c = 'X',
				EndPoint_ContractManager__c = 'X', EndPoint_PaymentManager__c = 'X', EndPoint_RVManager__c = 'X', PriceCalcCompanyParam__c = 'X',Endpoint_SORbyONF__c = 'test',EndPoint_GetStock__c='https://osbdev.pramericas.com/JDE9/Inventory/GetStock?wsdl'); 
	
		Account acc = [SELECT Id, OwnerId, Client_code_An8__c FROM Account LIMIT 1];
		User vendas = [SELECT Id FROM User WHERE id = :acc.OwnerId];
		LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;

        Test.startTest();
        
		
        LAT_OpportunityHandlerJSON pedidoJSON = createPedidoJSON(acc, prod1, paymentCondition, false);
        
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        
        LAT_Rest_OpportunityFlex.acc = acc;	
        Map<Id, LAT_Product__c> mapProds = new Map<Id, LAT_Product__c>();
        mapProds.put(prod1.Id, prod1);
        LAT_Rest_OpportunityFlex.mapProdById = mapProds;
        Map<String, Decimal> mapPriceBySku = new Map<String, Decimal>();
        mapPriceBySku.put(prod1.Id, 100);
        LAT_Rest_OpportunityFlex.mapPriceBySku = mapPriceBySku;
		LAT_Opportunity__c opp = LAT_Rest_OpportunityFlex.insertOpportunity(pedidoJSON);
		pedidoJSON.Header.ID = opp.Id;
        List<LAT_OpportunityLineItem__c> lines = [SELECT Id FROM LAT_OpportunityLineItem__c LIMIT 1];
        pedidoJSON.detail[0].Id = lines[0].Id;

        try{LAT_Rest_OpportunityFlexEDI.processOpportunity(pedidoJSON);}catch(Exception e){}
		
		Test.stopTest();

	}


	@isTest
	static  void testParse() {
		String json = '{'+
		'  \"header\": {'+
		'    \"id\": \"58e7c7f4\",'+
		'    \"owner\": null,'+
		'    \"name\": \"B2W COMPANHIA GLOBAL DO VAREJO - 17/10/2018\",'+
		'    \"account\": \"001D0000015iAB7IAM\",'+
		'    \"customerOrderNr\": \"PRueba Javi #3 18/10.\",'+
		'    \"accountAN8\": \"172811\",'+
		'    \"businessUnit\": \"17\",'+
		'    \"freighpetTy\": null,'+
		'    \"message1\": null,'+
		'    \"message2\": null,'+
		'    \"flexJustification\": null,'+
		'    \"lastItemModifiedDate\": \"2018-10-17T19:57:42.705Z\",'+
		'    \"creationDateTime\": \"2018-10-17T19:57:42.705Z\",'+
		'    \"jdeOrderNumber\": null,'+
		'    \"source\": null,'+
		'    \"type\": \"SO\",'+
		'    \"type_Z\": \"SO\",'+
		'    \"stage\": \"Mobile Order\",'+
		'    \"closeDate\": \"2018-10-17T19:55:32.962Z\",'+
		'    \"deliveryDate\": \"2018-10-17T03:00:00.000Z\",'+
		'    \"sugestedDeliveryDate\": \"\",'+
		'    \"totalAmmount\": 31881.360000000004,'+
		'    \"totalBoxes\": null,'+
		'    \"recordType\": null,'+
		'    \"hasBackorder\": null,'+
		'    \"creditLimitBalance\": null,'+
		'    \"parentAccount\": null,'+
		'    \"actionCode\": null,'+
		'    \"LastModifiedDate\": null,'+
		'    \"mxPaymentCondition\": \"a4yD0000000Ce63IAC\",'+
		'    \"mxPurchaseOrderSince\": \"\",'+
		'    \"mxPurchaseOrderUntil\": \"\",'+
		'    \"mxCreditCollectionsStatus\": null,'+
		'    \"mxLogisticsStatus\": null,'+
		'    \"currency\": \"BRL\",'+
		'    \"totalFreightPercent\": 3.0,'+
		'    \"totalPalletQuantity\": 0.01,'+
		'    \"marginalContribution\": null,'+
		'    \"isFlex\": false'+
		'  },'+
		'  \"detail\": ['+
		'    {'+
		'      \"id\": \"e142\",'+
		'      \"product\": \"aPZD0000000CaR7\",'+
		'      \"productSKU\": \"146\",'+
		'      \"PriceBookEntryId\": \"aPZD0000000CaR7\",'+
		'      \"paymentCondition\": \"V00\",'+
		'      \"measurementUnit\": \"CA\",'+
		'      \"maxDiscount\": null,'+
		'      \"quantity\": 1.0,'+
		'      \"discount\": 7.0,'+
		'      \"sendDicountToApproval\": false,'+
		'      \"unitPrice\": 0.0,'+
		'      \"totalPrice\": 18818.34,'+
		'      \"bottlesPerBox\": \"12\",'+
		'      \"lineStatus\": null,'+
		'      \"statusDescription\": null,'+
		'      \"retentionCode\": null,'+
		'      \"backorder\": 0.0,'+
		'      \"quantityBonus\": null,'+
		'      \"percentualBonus\": null,'+
		'      \"totalQuantity\": 0.0,'+
		'      \"totalPriceBR\": 18818.34,'+
		'      \"bottlePrice\": null,'+
		'      \"actionCode\": null,'+
		'      \"skuFreightPercentIndividual\": 0.18,'+
		'      \"skuFreightPercent\": 1.6199999999999999,'+
		'      \"skuPalletQuantity\": 0.0,'+
		'      \"indexMarca\": null,'+
		'      \"detailAmmountSummaryType\": null,'+
		'      \"detailAmmountSummaryType_ID\": null,'+
		'      \"isFlex\": true'+
		'    }'+
		'  ]'+
		'}';
		LAT_OpportunityHandlerJSON r = LAT_OpportunityHandlerJSON.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_OpportunityHandlerJSON objJSON2Apex = new LAT_OpportunityHandlerJSON(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_OpportunityHandlerJSON.Header objHeader = new LAT_OpportunityHandlerJSON.Header(System.JSON.createParser(json));
		

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_OpportunityHandlerJSON.Detail objDetail = new LAT_OpportunityHandlerJSON.Detail(System.JSON.createParser(json));
		
	}

	public static LAT_OpportunityHandlerJSON createPedidoJSON(Account acc, LAT_Product__c prod1, UDC__c paymentCondition, Boolean isFlex) {
		LAT_OpportunityHandlerJSON pedidoJSON = new LAT_OpportunityHandlerJSON();

        pedidoJSON.header.id  = 'fd664e59';
      	pedidoJSON.header.owner = null;
      	pedidoJSON.header.name 	= 'TEST 1';
      	pedidoJSON.header.account =  acc.Id;
      	pedidoJSON.header.customerOrderNr =  '1183762';
      	pedidoJSON.header.accountAN8 = '104066';
      	pedidoJSON.header.businessUnit	 = '17';
      	pedidoJSON.header.freighpetTy 	= null;
		pedidoJSON.header.message1 =  null;
		pedidoJSON.header.message2 =  null;
		pedidoJSON.header.lastItemModifiedDate = String.valueOf(Datetime.now());
		pedidoJSON.header.creationDateTime = '2018-09-24T00:31:41.442Z';
		pedidoJSON.header.jdeOrderNumber = null;
		pedidoJSON.header.source =  null;
		pedidoJSON.header.type_Z= 'SO';
		pedidoJSON.header.stage = 'Mobile Order';
		pedidoJSON.header.closeDate = String.valueOf(Datetime.now());
		pedidoJSON.header.deliveryDate = String.valueOf(Datetime.now());
		pedidoJSON.header.sugestedDeliveryDate =  '';
		pedidoJSON.header.totalAmmount = 6226.74;
		pedidoJSON.header.totalBoxes = null;
		pedidoJSON.header.recordType = null;
		pedidoJSON.header.hasBackorder = null;
		pedidoJSON.header.creditLimitBalance = null;
		pedidoJSON.header.parentAccount = null;
		pedidoJSON.header.actionCode = null;
		pedidoJSON.header.LastModifiedDate =null;
		pedidoJSON.header.mxPaymentCondition = paymentCondition.Id;
		pedidoJSON.header.mxPurchaseOrderSince = '';
		pedidoJSON.header.mxPurchaseOrderUntil = '';
		pedidoJSON.header.mxCreditCollectionsStatus = null;
		pedidoJSON.header.mxLogisticsStatus = null;
		pedidoJSON.header.totalFreightPercent = 1.0;
		pedidoJSON.header.totalPalletQuantity = 0.19;
		pedidoJSON.header.isFlex = true;
		pedidoJSON.header.flexJustification = 'El cliente es muy bueno con nosotros';
		pedidoJSON.header.flexApproveManager = false;
        pedidoJSON.header.flexApproveAreaManager = false;
        pedidoJSON.header.flexApproveRegionalManager = false;
        pedidoJSON.header.flexApproveCommercialDirector = false;

		pedidoJSON.Detail[0].id  = 'fd664e59';
		pedidoJSON.Detail[0].product = prod1.Id;
		pedidoJSON.Detail[0].productSKU = '5666';
		pedidoJSON.Detail[0].PriceBookEntryId = prod1.Id;
		pedidoJSON.Detail[0].paymentCondition = 'V42';
		pedidoJSON.Detail[0].measurementUnit = 'CA';
		pedidoJSON.Detail[0].maxDiscount = null;
		pedidoJSON.Detail[0].quantity = 7.0;
		pedidoJSON.Detail[0].discount = -7;
		pedidoJSON.Detail[0].sendDicountToApproval = false;
		pedidoJSON.Detail[0].unitPrice = 0.0;
		pedidoJSON.Detail[0].totalPrice = 2693.9500000000003;
		pedidoJSON.Detail[0].bottlesPerBox = '3';
		pedidoJSON.Detail[0].lineStatus = null;
		pedidoJSON.Detail[0].statusDescription = null;
		pedidoJSON.Detail[0].retentionCode = null;
		pedidoJSON.Detail[0].backorder = 0.0;
		pedidoJSON.Detail[0].quantityBonus = null;
		pedidoJSON.Detail[0].percentualBonus = null;
		pedidoJSON.Detail[0].totalQuantity = 0.0;
		pedidoJSON.Detail[0].totalPriceBR = 2693.9500000000003;
		pedidoJSON.Detail[0].bottlePrice = null;
		pedidoJSON.Detail[0].actionCode = null;
		pedidoJSON.Detail[0].skuFreightPercentIndividual = 0.05;
		pedidoJSON.Detail[0].skuFreightPercent = 0.35000000000000003;
		pedidoJSON.Detail[0].skuPalletQuantity = 0.04;
		pedidoJSON.Detail[0].detailAmmountSummaryType = null;
		pedidoJSON.Detail[0].detailAmmountSummaryType_ID = null;
		pedidoJSON.Detail[0].isFlex =isFlex;
		pedidoJSON.Detail[0].isOkEDI =true;
		return pedidoJSON;

	}

}