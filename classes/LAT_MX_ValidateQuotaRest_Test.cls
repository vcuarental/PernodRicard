@isTest
private class LAT_MX_ValidateQuotaRest_Test {
	
	@isTest static void test_method_one() {

        setup();
        Id accId = createAccount();
        Test.startTest();
        Id prod1Id = createProduct('Test 1', '123');
        Id prod2Id = createProduct('Test 2', '124');
        
        LAT_MX_QTA_Quota__c quota1 = new LAT_MX_QTA_Quota__c(
            LAT_MX_Client__c = accId,
            LAT_Product__c = prod1Id,
            LAT_MX_Quota__c = 100,
            LAT_MX_ValiditySince__c = date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_QTA_Quota__c' + 'LAT_MX_QTA_Standard'),
            LAT_MX_ValidityUntil__c = date.today()
        
        );
        
        insert quota1;

        LAT_MX_ValidateQuotaRest.LineaPedido linea1 = new LAT_MX_ValidateQuotaRest.LineaPedido();
        linea1.Product 	= prod1Id;
        linea1.Quantity	= 200;
        LAT_MX_ValidateQuotaRest.LineaPedido linea2 = new LAT_MX_ValidateQuotaRest.LineaPedido();
        linea2.Product 	= prod2Id;
        linea2.Quantity	= 200;
        List<LAT_MX_ValidateQuotaRest.LineaPedido> lista = new List<LAT_MX_ValidateQuotaRest.LineaPedido>{linea1,linea2};

        LAT_MX_ValidateQuotaRest.post(lista, accId);
        Test.stopTest();
	}
	
	private static Id createAccount() {
		UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;
                    
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        
        update acc;
        return acc.Id;
	}

	private static Id createProduct(String name, String sku){
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = name,
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '12-'+sku,
            LAT_QTLeadTime__c = 5,
            LAT_SKU__c = sku,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;
        return prod1.Id;
	}

	private static void setup() {
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(name ='MX_IndexMarca_Notification_Users', LAT_Value__C = '1');
        insert cfg;
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@test.com');
        insert cfg2;
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(name ='MX_DEFAULT_INDEX_MARGIN', LAT_Value__C = '2');
        insert cfg1;

       	LAT_CHATTER_POST_BODY__c cpb = new LAT_CHATTER_POST_BODY__c();
        cpb.Name = 'LAT_MX_ProductoSinIndexMarca';
        cpb.Body__c = 'Tests';
        insert cpb;

     	RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
	    req.requestURI = 'https://na11.salesforce.com';  // sample Endpoint
	    req.httpMethod = 'POST';

	    RestContext.request = req;
	    RestContext.response = res;

	}
}