@isTest
public class LAT_RestCheckStockAvailability_Test {
	
	private static Account init() {
		UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = '12 Dias MX - Test',
            Internal_Id__c = '12-123-CRM-PT',
            CodUs__c = 'PT',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc;
		UDC__c udc2 = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = 'MX - Test',
            Internal_Id__c = '12-123-CRM-DF',
            CodUs__c = 'DF',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc2;

		Account a = LAT_Account_TestFactory.getAccountBase('LAT_MX_ACC_OffTrade');
				
		a.CNPJ__c = 'LOZM701213E52'; 
		a.Payment_Condition__c = udc.id;
		a.Business_Unit_AR__c = udc2.id; 
		a.LAT_MX_AvailableCreditLimit__c = 100.00;
		a.Client_country_AN8__c =  '12-1234';
		insert a;

		LAT_Product__c LAT_produto = new LAT_Product__c();
	    LAT_produto.Name = 'Test1';
	    LAT_produto.LAT_IsActive__c = true;
	    LAT_produto.LAT_CDUnit__c = 'UN';
	    LAT_produto.LAT_ExternalID__c = '444';
	    LAT_produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'LAT_MX_PRD_Standard' );
	    insert LAT_produto;

		LAT_Product__c LAT_produto2 = new LAT_Product__c();
	    LAT_produto2.Name = 'Test2';
	    LAT_produto2.LAT_IsActive__c = true;
	    LAT_produto2.LAT_CDUnit__c = 'UN';
	    LAT_produto2.LAT_ExternalID__c = '3333';
	    LAT_produto2.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'LAT_MX_PRD_Standard' );
	    insert LAT_produto2;

	    Lat_stock__c lStock = new Lat_stock__c();
	    lstock.LAT_Product__c = LAT_produto.id;
	    lStock.LAT_Branch__c = 'DHCJ';
	    lStock.LAT_Unit__c = 'C9';
	    lstock.LAT_Stock__c = 500;
	    lStock.LAT_ExternalId__c = '12-444';
	    insert lStock;

	    return a;
	}
	


	public static Lat_GetStockTypes.ItemListResponseType getResponse(){
	    Lat_GetStockTypes.ItemListResponseType response = new Lat_GetStockTypes.ItemListResponseType();
	    response.itemResponse = new List<Lat_GetStockTypes.ItemResponseType>();

	    Lat_GetStockTypes.ItemResponseType responseType = new Lat_GetStockTypes.ItemResponseType();
	    responseType.businessUnit = 'null';
	    responseType.sku = '444';
	    responseType.response = '1200.76';
	    response.itemResponse.add(responseType);

	    responseType = new Lat_GetStockTypes.ItemResponseType();
	    responseType.businessUnit = 'null';
	    responseType.response = '0';
	    responseType.sku = '3333';
	    responseType.errorJDE = 'Error';
	    response.itemResponse.add(responseType);
	    
	    return response;
	}

	@isTest static void test_method_one() {
		Account a = init();

		Test.startTest();
		String JSONMsg = '{"skus":["444","3333"], "accId" : "'+a.Id+'", "unitOfMeasure" : null}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/LAT_RestCheckStockAvailability/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
     
        LAT_RestCheckStockAvailability.post(new String[] {'444','3333'}, a.Id, null );
        LAT_RestCheckStockAvailability.getConnectionParameter('12');
        Test.StopTest();   
	}
	
	
}