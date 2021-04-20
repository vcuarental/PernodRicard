@isTest
private class LAT_Rest_ValidateFlexApprovals_Test {
	
	@testSetup
	public static void setup(){
		LAT_Rest_OpportunityFlex_Test.setup();
	}

	@isTest static void test_method_one() {
		User vendas = [SELECT Id FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true LIMIT 1];
		Account acc = [SELECT Id, LAT_Account__r.LAT_JDEZone__c, Client_code_An8__c FROM Account LIMIT 1];
		LAT_Account__c latAcc = [SELECT Id, LAT_JDEZone__c FROM LAT_Account__c WHERE LAT_AccountID__c = :acc.Id LIMIT 1];

		acc.OwnerID = vendas.Id;
		acc.Client_code_An8__c = '1111';
		acc.Client_country_An8__c = '1-1111';
		acc.CurrencyISOCode = 'BRL';
		//update acc;
        
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', LAT_Scheduler__c = 'ABT', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;
        Test.startTest();
        LAT_OpportunityHandlerJSON pedidoJSON = LAT_Rest_OpportunityFlex_Test.createPedidoJSON(acc, prod1, paymentCondition);
        pedidoJSON.Detail[0].discount = -7;
        pedidoJSON.Detail[0].finalFlexDiscount = -7;
        RestRequest req = new RestRequest();

        req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
		RestContext.request = req;
		RestContext.response = new RestResponse();

		System.runAs(vendas) {	
			Map<String,String> mapa = new Map<String,String>();
        	mapa.put('ANY key', 'ANY value');
        	String mockbody = '[{"regionCode": "3","brandCode": "ABT", "accountId": 3,"channelCode": "ON","minPercentExecutive": 9, "minPercentManager": 6, "minPercentRegionalManager": 10, "minPercentCommercialDirector": 11},{"minPercentExecutive": 9, "minPercentManager": 6, "minPercentRegionalManager": 10, "minPercentCommercialDirector": 11}]';
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status',mockbody , mapa));	
			LAT_Rest_ValidateFlexApprovals.process();
			LAT_Rest_ValidateFlexApprovals.mockResponse();
		}
		
		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		LAT_IMM_Logs__c log = new LAT_IMM_Logs__c();
		insert log;
		update log;
	}
	
}