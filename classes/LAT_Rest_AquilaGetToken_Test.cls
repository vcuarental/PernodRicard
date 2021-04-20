@isTest
private class LAT_Rest_AquilaGetToken_Test {
	
	@testSetup
	static void setup() {
		LAT_IMM_Operations__c op = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c =LAT_Rest_AquilaGetToken.GET_TOKEN, Service_Name_Header__c='IMM', Name = LAT_Rest_AquilaGetToken.GET_TOKEN, Http_operation__c='POST', x_Api_key__c='FzH%pH32dyPU*F3B');
		insert op;
	}

	@isTest static void test_Success() {
		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('Sdtmsg', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', getSuccessBody(), mapa));
		System.runAs(getVendasUser()){
			LAT_Rest_AquilaGetToken.GET();
		}
		Test.stopTest();
	}
	
	@isTest static void test_Error() {
		Test.startTest();
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		RestContext.request = req;
		RestContext.response = res;
		Map<String,String> mapa = new Map<String,String>();
		mapa.put('Sdtmsg', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', getErrorBody(), mapa));
		
		System.runAs(getVendasUser()){
			LAT_Rest_AquilaGetToken.GET();
		}
		
		Test.stopTest();
	}

	public static String getSuccessBody(){
		return '{"token": "Test"}';
	}

	public static String getErrorBody(){
		return '{"message": "Invalid email","error": {}}';
	}

	public static User getVendasUser(){
		return [SELECT Id, Email FROM User WHERE IsActive = true AND Profile.Name = 'LAT_BR2_Vendas' AND Email <> null LIMIT 1];
	}	
}