@IsTest(IsParallel = true)
private class EUR_CRM_SKURestResourceTest {

	private static final String B_EXT_ID = 'B_EXT_ID';
	private static final String BQ_EXT_ID = 'BQ_EXT_ID';
	private static final String BQS_EXT_ID = 'BQS_EXT_ID';
	private static final String SKU_EXT_ID = 'SKU_EXT_ID';


	//SKU by ExtId not exists, BQS with ExtId exists
	//create new SKU with populated fields
	@IsTest
	private static void skuNotExists_BQSByExtIdNotExists_CreateNewSKU_PositiveTest() {
		EUR_CRM_Brand__c b = makeB(B_EXT_ID);
		insert b;

		EUR_CRM_Quality__c bq = makeBQ(b.Id, BQ_EXT_ID);
		insert bq;

		EUR_CRM_Size__c bqs = makeBQS(bq, 10);
		insert bqs;

		EUR_CRM_SKURestResource.SKUResource skuResource = new EUR_CRM_SKURestResource.SKUResource();
		skuResource.Affiliate = 'DE';
		skuResource.TradeItemName = 'Test';
		skuResource.ExternalID = 'Test EUR_CRM_SKU_Code__c';
		skuResource.TradeItemGTINBottle = 'Test glnBottle';
		skuResource.TradeItemGTINCase = 'Test glnCase';
		skuResource.BrandQualityCode = bq.EUR_CRM_External_ID__c;
		skuResource.BottleSize = '10';
		skuResource.Status = 'Active';
		skuResource.UnitOfMeasure = 'Bottle';
		skuResource.TradeItemType = 'Convivio';
		skuResource.BottlesPerCase = '14';
		skuResource.CasesPerPallet = '15';
		skuResource.CasesPerLayer = '16';

		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

//		request.addParameter(EUR_CRM_SKURestResource.EXT_ID_PARAM, SKU_EXT_ID);
		request.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/products/'+SKU_EXT_ID;
		request.requestBody = Blob.valueOf(JSON.serializePretty(skuResource));
		request.httpMethod = 'PUT';

		RestContext.request = request;
		RestContext.response = response;

		//Assertion before
		System.assertEquals(0, selectSKUs().size());

		Test.startTest();
		EUR_CRM_SKURestResource.doPut();
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> newSKUs = selectSKUs();
		System.debug('\n newSKUs.size() => ' + newSKUs.size() + '\n');
		System.debug('\n newSKUs => ' + JSON.serializePretty(newSKUs) + '\n');
		System.debug('\n RestContext.response.responseBody.size() => ' + RestContext.response.responseBody.size() + '\n');
		System.debug('\n RestContext.response.responseBody => ' + JSON.serializePretty(RestContext.response.responseBody.toString()) + '\n');
		EUR_CRM_SKURestResource.SKUResource skuResAfter = (EUR_CRM_SKURestResource.SKUResource)JSON.deserialize(RestContext.response.responseBody.toString(), EUR_CRM_SKURestResource.SKUResource.class);
		System.debug('\n skuResAfter => ' + JSON.serializePretty(skuResAfter) + '\n');
		System.assertEquals(1, newSKUs.size());

		System.assertEquals(newSKUs[0].Name, skuResource.TradeItemName);
		System.assertEquals(newSKUs[0].EUR_CRM_SKU_Code__c, skuResource.ExternalID);
		System.assertEquals(newSKUs[0].EUR_CRM_EAN_Bottle__c, skuResource.TradeItemGTINBottle);
		System.assertEquals(newSKUs[0].EUR_CRM_EAN_Carton__c, skuResource.TradeItemGTINCase);
		System.assertEquals('Active', skuResource.Status);
		// System.assertEquals(newSKUs[0].EUR_CRM_Unit_Type__c, skuResource.UnitOfMeasure);
		System.assertEquals(newSKUs[0].EUR_CRM_Product_Usage__c, skuResource.TradeItemType);
		System.assertEquals(newSKUs[0].EUR_CRM_Bottles_per_Case__c, Decimal.valueOf(skuResource.BottlesPerCase));
		System.assertEquals(newSKUs[0].EUR_CRM_Cases_per_Pallet__c, Decimal.valueOf(skuResource.CasesPerPallet));
		System.assertEquals(newSKUs[0].EUR_CRM_Cartons_in_Layer__c, Decimal.valueOf(skuResource.CasesPerLayer));
		System.assertEquals(newSKUs[0].EUR_CRM_Cartons_in_Layer__c, Decimal.valueOf(skuResource.CasesPerLayer));
		System.assertEquals('EUR_DE_SKU', newSKUs[0].RecordType.DeveloperName);
		System.assertEquals(bqs.Id, newSKUs[0].EUR_CRM_Brand_Quality_Size__c);

	}


	//SKU by ExtId not exists, BQS with ExtId not exists
	//return an error
	@IsTest
	private static void skuNotExists_BQSByExtIdNotExists_ReturnError_NegativeTest() {
		EUR_CRM_Brand__c b = makeB(B_EXT_ID);
		insert b;

		EUR_CRM_Quality__c bq = makeBQ(b.Id, BQ_EXT_ID);
		insert bq;

		EUR_CRM_Size__c bqs = makeBQS(bq, 10);
		insert bqs;

		EUR_CRM_SKURestResource.SKUResource skuResource = new EUR_CRM_SKURestResource.SKUResource();
		skuResource.Affiliate = 'DE';
		skuResource.TradeItemName = 'Test';
		skuResource.ExternalID = 'Test EUR_CRM_SKU_Code__c';
		skuResource.TradeItemGTINBottle = 'Test glnBottle';
		skuResource.TradeItemGTINCase = 'Test glnCase';
		skuResource.BrandQualityCode = bq.EUR_CRM_External_ID__c;
		skuResource.BottleSize = '13';
		skuResource.Status = 'Active';
		skuResource.UnitOfMeasure = 'Bottle';
		skuResource.TradeItemType = 'Convivio';
		skuResource.BottlesPerCase = '14';
		skuResource.CasesPerPallet = '15';
		skuResource.CasesPerLayer = '16';

		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

//		request.addParameter(EUR_CRM_SKURestResource.EXT_ID_PARAM, SKU_EXT_ID);
		request.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/products/'+SKU_EXT_ID;
		request.requestBody = Blob.valueOf(JSON.serializePretty(skuResource));
		request.httpMethod = 'PUT';

		RestContext.request = request;
		RestContext.response = response;

		//Assertion before
		System.assertEquals(0, selectSKUs().size());

		Test.startTest();
		EUR_CRM_SKURestResource.doPut();
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> newSKUs = selectSKUs();
		String bqsExtId = EUR_CRM_SKURestResource.getBQSExternalId(skuResource);
		System.debug('\n RestContext.response.responseBody => ' + JSON.serializePretty(RestContext.response.responseBody.toString()) + '\n');
		System.assertEquals('"Can not create SKU, no found BQS with External Id: ' + bqsExtId +'"',JSON.serializePretty(RestContext.response.responseBody.toString()));
		System.assertEquals(0, newSKUs.size());

	}

	//SKU by ExtId exists
	//update SKU
	@IsTest
	private static void skuExists_UpdateSKU_PositiveTest() {
		EUR_CRM_Brand__c b = makeB(B_EXT_ID);
		insert b;

		EUR_CRM_Quality__c bq = makeBQ(b.Id, BQ_EXT_ID);
		insert bq;

		EUR_CRM_Size__c bqs = makeBQS(bq, 10);
		insert bqs;

		EUR_CRM_SKU__c sku = makeSKU(bqs.Id, SKU_EXT_ID);
		insert sku;

		EUR_CRM_SKURestResource.SKUResource skuResource = new EUR_CRM_SKURestResource.SKUResource();
		skuResource.Affiliate = 'DE';
		skuResource.TradeItemName = 'Test';
		skuResource.ExternalID = 'Test EUR_CRM_SKU_Code__c';
		skuResource.TradeItemGTINBottle = 'Test glnBottle';
		skuResource.TradeItemGTINCase = 'Test glnCase';
		skuResource.BrandQualityCode = bq.EUR_CRM_External_ID__c;
		skuResource.BottleSize = '10';
		skuResource.Status = 'Active';
		skuResource.UnitOfMeasure = 'Bottle';
		skuResource.TradeItemType = 'Convivio';
		skuResource.BottlesPerCase = '14';
		skuResource.CasesPerPallet = '15';
		skuResource.CasesPerLayer = '16';

		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

//		request.addParameter(EUR_CRM_SKURestResource.EXT_ID_PARAM, SKU_EXT_ID);
		request.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/products/'+SKU_EXT_ID;
		request.requestBody = Blob.valueOf(JSON.serializePretty(skuResource));
		request.httpMethod = 'PUT';

		RestContext.request = request;
		RestContext.response = response;

		//Assertion before
		System.assertEquals(1, selectSKUs().size());

		Test.startTest();
		EUR_CRM_SKURestResource.doPut();
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> newSKUs = selectSKUs();
		System.assertEquals(1, newSKUs.size());
		System.debug('\n newSKUs.size() => ' + newSKUs.size() + '\n');
		System.debug('\n newSKUs => ' + JSON.serializePretty(newSKUs) + '\n');
		System.debug('\n RestContext.response.responseBody.size() => ' + RestContext.response.responseBody.size() + '\n');
		System.debug('\n RestContext.response.responseBody => ' + JSON.serializePretty(RestContext.response.responseBody.toString()) + '\n');
		EUR_CRM_SKURestResource.SKUResource skuResAfter = (EUR_CRM_SKURestResource.SKUResource)JSON.deserialize(RestContext.response.responseBody.toString(), EUR_CRM_SKURestResource.SKUResource.class);
		System.debug('\n skuResAfter => ' + JSON.serializePretty(skuResAfter) + '\n');

		System.assertEquals(newSKUs[0].Name, skuResource.TradeItemName);
		System.assertEquals(newSKUs[0].EUR_CRM_SKU_Code__c, skuResource.ExternalID);
		System.assertEquals(newSKUs[0].EUR_CRM_EAN_Bottle__c, skuResource.TradeItemGTINBottle);
		System.assertEquals(newSKUs[0].EUR_CRM_EAN_Carton__c, skuResource.TradeItemGTINCase);
		System.assertEquals('Active', skuResource.Status);
		System.assertEquals(newSKUs[0].EUR_CRM_Unit_Type__c, skuResource.UnitOfMeasure);
		// System.assertEquals(newSKUs[0].EUR_CRM_Product_Usage__c, skuResource.TradeItemType);
		System.assertEquals(newSKUs[0].EUR_CRM_Bottles_per_Case__c, Decimal.valueOf(skuResource.BottlesPerCase));
		System.assertEquals(newSKUs[0].EUR_CRM_Cases_per_Pallet__c, Decimal.valueOf(skuResource.CasesPerPallet));
		System.assertEquals(newSKUs[0].EUR_CRM_Cartons_in_Layer__c, Decimal.valueOf(skuResource.CasesPerLayer));
		System.assertEquals(newSKUs[0].EUR_CRM_Cartons_in_Layer__c, Decimal.valueOf(skuResource.CasesPerLayer));
		//System.assertEquals('EUR_DE_SKU', newSKUs[0].RecordType.DeveloperName);
	}


	private static EUR_CRM_Brand__c makeB(String extId) {
		return new EUR_CRM_Brand__c(
			EUR_CRM_External_ID__c = extId
		);
	}

	private static EUR_CRM_Quality__c makeBQ(Id bId, String extId) {
		return new EUR_CRM_Quality__c(
			EUR_CRM_Brand__c = bId
			,	EUR_CRM_External_ID__c = extId
		);
	}

	private static EUR_CRM_Size__c makeBQS(EUR_CRM_Quality__c bq, Decimal bottleSizeCl) {
		return new EUR_CRM_Size__c(
			EUR_CRM_Brand_Quality__c = bq.Id
		,	EUR_CRM_Bottle_Size_cl__c = bottleSizeCl
		,	EUR_CRM_External_ID__c = bq.EUR_CRM_External_ID__c + '_' + Integer.valueOf(bottleSizeCl)
		);
	}

	private static EUR_CRM_SKU__c makeSKU(Id bqsId, String extId) {
		return new EUR_CRM_SKU__c(
			EUR_CRM_Brand_Quality_Size__c = bqsId
			,	EUR_CRM_External_ID__c = extId
		);
	}


	private static List<EUR_CRM_SKU__c> selectSKUs() {
		return [
			SELECT Id
				,   Name
				,   EUR_CRM_SKU_Code__c
				,   EUR_CRM_EAN_Bottle__c
				,   EUR_CRM_EAN_Carton__c
				,   EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_External_ID__c
				,   EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Bottle_Size__c
				,   EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Bottle_Size_cl__c
				,   EUR_CRM_Bottle_Size_Litre__c
				,   EUR_CRM_Active__c
				,   EUR_CRM_Unit_Type__c
				,   EUR_CRM_Bottles_per_Case__c
				,   EUR_CRM_Cases_per_Pallet__c
				,   EUR_CRM_Cartons_in_Layer__c
				,   RecordType.DeveloperName
				,   EUR_CRM_Product_Usage__c
				,   EUR_CRM_External_ID__c
			FROM EUR_CRM_SKU__c
		];
	}

}