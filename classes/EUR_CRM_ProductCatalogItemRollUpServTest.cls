@IsTest(IsParallel = true)
private class EUR_CRM_ProductCatalogItemRollUpServTest {

	private static Integer RECORDS_COUNT = 5;

	//BQS RTs
	private static final String EUR_GB_SIZE = 'EUR_GB_Size';

	//SKU RTs
	private static final String EUR_GB_SKU = 'EUR_GB_SKU';

	//POSM RTs
	private static final String EUR_AT_POS_MATERIAL = 'EUR_AT_POS_Material';

	//PC RTs
	public static final String EUR_DIRECT = 'EUR_Direct';

	
	//After insert tests
	@IsTest
	private static void onAfterInsert_Case1_Positive() {
		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(0, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_SKU__c = sku1.Id;
		insert pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(1, skusAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterInsert_Case2_Positive() {
		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(0, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, bqsAfter.size());
		System.assertEquals(1, bqsAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterInsert_Case3_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(1, posmBefore.size());
		System.assertEquals(0, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		insert pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(1, posmAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterInsert_Case4_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();

		System.assertEquals(1, posmBefore.size());
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(0, posmBefore[0].EUR_CRM_PBI_count__c);
		System.assertEquals(0, skusBefore[0].EUR_CRM_PBI_count__c);
		System.assertEquals(0, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		pci1.EUR_CRM_SKU__c = sku1.Id;
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(1, bqsAfter.size());

		System.assertEquals(1, posmAfter[0].EUR_CRM_PBI_count__c);
		System.assertEquals(1, skusAfter[0].EUR_CRM_PBI_count__c);
		System.assertEquals(1, bqsAfter[0].EUR_CRM_PBI_count__c);
	}


	//After update tests
	@IsTest
	private static void onAfterUpdate_Case1_Positive() {
		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_SKU__c = sku1.Id;
		insert pci1;

		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(1, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		pci1.EUR_CRM_SKU__c = null;
		update pci1;
		Test.stopTest();

		System.debug('\n pci1 => ' + JSON.serializePretty(pci1) + '\n');

		//Assertion before
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(0, skusAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterUpdate_Case2_Positive() {
		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_SKU__c = null;
		insert pci1;

		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(0, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		pci1.EUR_CRM_SKU__c = sku1.Id;
		update pci1;
		Test.stopTest();

		//Assertion before
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(1, skusAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterUpdate_Case3_Positive() {
		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert pci1;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(1, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		pci1.EUR_CRM_Brand_Quality_Size__c = null;
		update pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, bqsAfter.size());
		System.assertEquals(0, bqsAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterUpdate_Case4_Positive() {
		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_Brand_Quality_Size__c = null;
		insert pci1;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(0, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		update pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, bqsAfter.size());
		System.assertEquals(1, bqsAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterUpdate_Case5_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		insert pci1;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(1, posmBefore.size());
		System.assertEquals(1, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		pci1.EUR_CRM_POS_Material__c = null;
		update pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(0, posmAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterUpdate_Case6_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = null;
		insert pci1;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(1, posmBefore.size());
		System.assertEquals(0, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		update pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(1, posmAfter[0].EUR_CRM_PBI_count__c);
	}


	//After delete tests
	@IsTest
	private static void onAfterDelete_Case1_Positive() {
		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_SKU__c = sku1.Id;
		insert pci1;

		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(1, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		delete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(0, skusAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterDelete_Case2_Positive() {
		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert pci1;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(1, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		delete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, bqsAfter.size());
		System.assertEquals(0, bqsAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterDelete_Case3_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		insert pci1;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(1, posmBefore.size());
		System.assertEquals(1, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		delete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(0, posmAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterDelete_Case4_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		pci1.EUR_CRM_SKU__c = sku1.Id;
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert pci1;
		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();

		System.assertEquals(1, posmBefore.size());
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(1, posmBefore[0].EUR_CRM_PBI_count__c);
		System.assertEquals(1, skusBefore[0].EUR_CRM_PBI_count__c);
		System.assertEquals(1, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		delete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(1, bqsAfter.size());

		System.assertEquals(0, posmAfter[0].EUR_CRM_PBI_count__c);
		System.assertEquals(0, skusAfter[0].EUR_CRM_PBI_count__c);
		System.assertEquals(0, bqsAfter[0].EUR_CRM_PBI_count__c);
	}


	//After undelete tests
	@IsTest
	private static void onAfterUndelete_Case1_Positive() {
		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_SKU__c = sku1.Id;
		insert pci1;

		delete pci1;
		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(0, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		undelete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(1, skusAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterUndelete_Case2_Positive() {
		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert pci1;

		delete pci1;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(0, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		undelete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, bqsAfter.size());
		System.assertEquals(1, bqsAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterUndelete_Case3_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		insert pci1;

		delete pci1;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(1, posmBefore.size());
		System.assertEquals(0, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		undelete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(1, posmAfter[0].EUR_CRM_PBI_count__c);
	}

	@IsTest
	private static void onAfterDUndelete_Case4_Positive() {
		EUR_CRM_POS_Material__c posm1 = makePOSM(EUR_AT_POS_MATERIAL);
		insert posm1;

		EUR_CRM_SKU__c sku1 = makeSKU(EUR_GB_SKU);
		insert sku1;

		EUR_CRM_Size__c bqs1 = makeBQS(EUR_GB_SIZE);
		insert bqs1;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		EUR_CRM_ProductCatalogItem__c pci1 = makePCI(pc.Id);
		pci1.EUR_CRM_POS_Material__c = posm1.Id;
		pci1.EUR_CRM_SKU__c = sku1.Id;
		pci1.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
		insert pci1;

		delete pci1;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();

		System.assertEquals(1, posmBefore.size());
		System.assertEquals(1, skusBefore.size());
		System.assertEquals(1, bqsBefore.size());
		System.assertEquals(0, posmBefore[0].EUR_CRM_PBI_count__c);
		System.assertEquals(0, skusBefore[0].EUR_CRM_PBI_count__c);
		System.assertEquals(0, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		undelete pci1;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(1, posmAfter.size());
		System.assertEquals(1, skusAfter.size());
		System.assertEquals(1, bqsAfter.size());

		System.assertEquals(1, posmAfter[0].EUR_CRM_PBI_count__c);
		System.assertEquals(1, skusAfter[0].EUR_CRM_PBI_count__c);
		System.assertEquals(1, bqsAfter[0].EUR_CRM_PBI_count__c);
	}


	//Mass after insert tests
	@IsTest
	private static void mass_onAfterInsert_Case1_Positive() {
		List<EUR_CRM_SKU__c> skus = (List<EUR_CRM_SKU__c>) makeProducts('EUR_CRM_SKU__c', EUR_GB_SKU);
		insert skus;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(5, skusBefore.size());
		System.assertEquals(0, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, skus);
		insert pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(5, skusAfter.size());
		for (EUR_CRM_SKU__c sku : skusAfter) {
			System.assertEquals(5, sku.EUR_CRM_PBI_count__c);
			System.assertEquals(5, sku.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterInsert_Case2_Positive() {
		List<EUR_CRM_Size__c> bqss = (List<EUR_CRM_Size__c>) makeProducts('EUR_CRM_Size__c', EUR_GB_SIZE);
		insert bqss;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(5, bqsBefore.size());
		System.assertEquals(0, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, bqss);
		insert pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(5, bqsAfter.size());
		for (EUR_CRM_Size__c bqs : bqsAfter) {
			System.assertEquals(5, bqs.EUR_CRM_PBI_count__c);
			System.assertEquals(5, bqs.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterInsert_Case3_Positive() {
		List<EUR_CRM_POS_Material__c> posms = (List<EUR_CRM_POS_Material__c>) makeProducts('EUR_CRM_POS_Material__c', EUR_AT_POS_Material);
		insert posms;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(5, posmBefore.size());
		System.assertEquals(0, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, posms);
		insert pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(5, posmAfter.size());
		for (EUR_CRM_POS_Material__c posm : posmAfter) {
			System.assertEquals(5, posm.EUR_CRM_PBI_count__c);
			System.assertEquals(5, posm.Price_Book_Items__r.size());
		}
	}


	//Mass after update tests
	@IsTest
	private static void mass_onAfterUpdate_Case1_Positive() {
		List<EUR_CRM_SKU__c> skus = (List<EUR_CRM_SKU__c>) makeProducts('EUR_CRM_SKU__c', EUR_GB_SKU);
		insert skus;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, skus);
		insert pcis;

		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(5, skusBefore.size());
		System.assertEquals(5, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		for (EUR_CRM_ProductCatalogItem__c pci : pcis) {
			pci.EUR_CRM_SKU__c = null;
		}
		update pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(5, skusAfter.size());
		for (EUR_CRM_SKU__c sku : skusAfter) {
			System.assertEquals(0, sku.EUR_CRM_PBI_count__c);
			System.assertEquals(0, sku.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterUpdate_Case2_Positive() {
		List<EUR_CRM_Size__c> bqss = (List<EUR_CRM_Size__c>) makeProducts('EUR_CRM_Size__c', EUR_GB_SIZE);
		insert bqss;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, bqss);
		insert pcis;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(5, bqsBefore.size());
		System.assertEquals(5, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		for (EUR_CRM_ProductCatalogItem__c pci : pcis) {
			pci.EUR_CRM_Brand_Quality_Size__c = null;
		}
		update pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(5, bqsAfter.size());
		for (EUR_CRM_Size__c bqs : bqsAfter) {
			System.assertEquals(0, bqs.EUR_CRM_PBI_count__c);
			System.assertEquals(0, bqs.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterUpdate_Case3_Positive() {
		List<EUR_CRM_POS_Material__c> posms = (List<EUR_CRM_POS_Material__c>) makeProducts('EUR_CRM_POS_Material__c', EUR_AT_POS_Material);
		insert posms;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, posms);
		insert pcis;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(5, posmBefore.size());
		System.assertEquals(5, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		for (EUR_CRM_ProductCatalogItem__c pci : pcis) {
			pci.EUR_CRM_POS_Material__c = null;
		}
		update pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(5, posmAfter.size());
		for (EUR_CRM_POS_Material__c posm : posmAfter) {
			System.assertEquals(0, posm.EUR_CRM_PBI_count__c);
			System.assertEquals(0, posm.Price_Book_Items__r.size());
		}
	}


	//Mass after delete tests
	@IsTest
	private static void mass_onAfterDelete_Case1_Positive() {
		List<EUR_CRM_SKU__c> skus = (List<EUR_CRM_SKU__c>) makeProducts('EUR_CRM_SKU__c', EUR_GB_SKU);
		insert skus;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, skus);
		insert pcis;

		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(5, skusBefore.size());
		System.assertEquals(5, skusBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		delete pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(5, skusAfter.size());
		for (EUR_CRM_SKU__c sku : skusAfter) {
			System.assertEquals(0, sku.EUR_CRM_PBI_count__c);
			System.assertEquals(0, sku.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterDelete_Case2_Positive() {
		List<EUR_CRM_Size__c> bqss = (List<EUR_CRM_Size__c>) makeProducts('EUR_CRM_Size__c', EUR_GB_SIZE);
		insert bqss;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, bqss);
		insert pcis;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(5, bqsBefore.size());
		System.assertEquals(5, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		delete pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(5, bqsAfter.size());
		for (EUR_CRM_Size__c bqs : bqsAfter) {
			System.assertEquals(0, bqs.EUR_CRM_PBI_count__c);
			System.assertEquals(0, bqs.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterDelete_Case3_Positive() {
		List<EUR_CRM_POS_Material__c> posms = (List<EUR_CRM_POS_Material__c>) makeProducts('EUR_CRM_POS_Material__c', EUR_AT_POS_Material);
		insert posms;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, posms);
		insert pcis;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(5, posmBefore.size());
		System.assertEquals(5, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		delete pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(5, posmAfter.size());
		for (EUR_CRM_POS_Material__c posm : posmAfter) {
			System.assertEquals(0, posm.EUR_CRM_PBI_count__c);
			System.assertEquals(0, posm.Price_Book_Items__r.size());
		}
	}


	//Mass after undelete tests
	@IsTest
	private static void mass_onAfterUndelete_Case1_Positive() {
		List<EUR_CRM_SKU__c> skus = (List<EUR_CRM_SKU__c>) makeProducts('EUR_CRM_SKU__c', EUR_GB_SKU);
		insert skus;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, skus);
		insert pcis;

		delete pcis;
		//Assertion before
		List<EUR_CRM_SKU__c> skusBefore = selectSKUs();
		System.assertEquals(5, skusBefore.size());
		System.assertEquals(0, skusBefore[0].EUR_CRM_PBI_count__c);


		Test.startTest();
		undelete pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_SKU__c> skusAfter = selectSKUs();
		System.assertEquals(5, skusAfter.size());
		for (EUR_CRM_SKU__c sku : skusAfter) {
			System.assertEquals(5, sku.EUR_CRM_PBI_count__c);
			System.assertEquals(5, sku.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterUndelete_Case2_Positive() {
		List<EUR_CRM_Size__c> bqss = (List<EUR_CRM_Size__c>) makeProducts('EUR_CRM_Size__c', EUR_GB_SIZE);
		insert bqss;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, bqss);
		insert pcis;

		delete pcis;

		//Assertion before
		List<EUR_CRM_Size__c> bqsBefore = selectBQSs();
		System.assertEquals(5, bqsBefore.size());
		System.assertEquals(0, bqsBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		undelete pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_Size__c> bqsAfter = selectBQSs();
		System.assertEquals(5, bqsAfter.size());
		for (EUR_CRM_Size__c bqs : bqsAfter) {
			System.assertEquals(5, bqs.EUR_CRM_PBI_count__c);
			System.assertEquals(5, bqs.Price_Book_Items__r.size());
		}
	}

	@IsTest
	private static void mass_onAfterUndelete_Case3_Positive() {
		List<EUR_CRM_POS_Material__c> posms = (List<EUR_CRM_POS_Material__c>) makeProducts('EUR_CRM_POS_Material__c', EUR_AT_POS_Material);
		insert posms;

		EUR_CRM_ProductCatalog__c pc = makePC(EUR_DIRECT);
		insert pc;

		List<EUR_CRM_ProductCatalogItem__c> pcis = makePCIs(pc.Id, posms);
		insert pcis;

		delete pcis;

		//Assertion before
		List<EUR_CRM_POS_Material__c> posmBefore = selectPOSMs();
		System.assertEquals(5, posmBefore.size());
		System.assertEquals(0, posmBefore[0].EUR_CRM_PBI_count__c);

		Test.startTest();
		undelete pcis;
		Test.stopTest();

		//Assertion after
		List<EUR_CRM_POS_Material__c> posmAfter = selectPOSMs();
		System.assertEquals(5, posmAfter.size());
		for (EUR_CRM_POS_Material__c posm : posmAfter) {
			System.assertEquals(5, posm.EUR_CRM_PBI_count__c);
			System.assertEquals(5, posm.Price_Book_Items__r.size());
		}
	}



	//Makers
	private static List<SObject> makeProducts(String sobjName, String rt) {
		List<SObject> sObjects = new List<SObject>();
		for (Integer i = 0; i < RECORDS_COUNT; i++) {
			switch on sobjName {
				when 'EUR_CRM_SKU__c' {
					sObjects.add(makeSKU(rt));
				}
				when 'EUR_CRM_Size__c' {
					sObjects.add(makeBQS(rt));
				}
				when 'EUR_CRM_POS_Material__c' {
					sObjects.add(makePOSM(rt));
				}
			}
		}
		return sObjects;
	}

	private static List<EUR_CRM_ProductCatalogItem__c> makePCIs(Id pciId, List<SObject> sObjects) {
		List<EUR_CRM_ProductCatalogItem__c> pcis = new List<EUR_CRM_ProductCatalogItem__c>();
		for (SObject sobj : sObjects) {
			for (Integer i = 0; i < RECORDS_COUNT; i++) {
				EUR_CRM_ProductCatalogItem__c pci = makePCI(pciId);
				if (sobj.getSObjectType() == EUR_CRM_SKU__c.SObjectType) {
					pci.EUR_CRM_SKU__c = sobj.Id;
				}
				if (sobj.getSObjectType() == EUR_CRM_Size__c.SObjectType) {
					pci.EUR_CRM_Brand_Quality_Size__c = sobj.Id;
				}
				if (sobj.getSObjectType() == EUR_CRM_POS_Material__c.SObjectType) {
					pci.EUR_CRM_POS_Material__c = sobj.Id;
				}
				pcis.add(pci);
			}

		}
		return pcis;
	}

	private static EUR_CRM_Size__c makeBQS(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Size__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Size__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_SKU__c makeSKU(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_SKU__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_SKU__c(
			RecordTypeId = rtId
		);
	}

	private static EUR_CRM_POS_Material__c makePOSM(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_POS_Material__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_POS_Material__c(
			RecordTypeId = rtId
		);
	}

	public static EUR_CRM_ProductCatalogItem__c makePCI(Id pcId) {
		return new EUR_CRM_ProductCatalogItem__c(
			EUR_CRM_PriceBookID__c = pcId
		);
	}

	public static EUR_CRM_ProductCatalog__c makePC(String rt) {
		Id rtId = SObjectType.EUR_CRM_ProductCatalog__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_ProductCatalog__c(
		    RecordTypeId = rtId
		,   Name = 'Standard Test Catalog'
		,   EUR_CRM_IsStandard__c = true
		,   EUR_CRM_IsManual__c = true
//		,   EUR_CRM_Country__c = EUR_CRM_CatalogCreationService.CURRENT_USER_CC
//		,   EUR_CRM_ValidTo__c = System.today().addDays(5)
//		,   EUR_CRM_ValidFrom__c = System.today().addDays(-2)
		);
	}


	//Selectors
	private static List<EUR_CRM_SKU__c> selectSKUs() {
		return [
			SELECT Id
			,   EUR_CRM_PBI_count__c
			,   (SELECT Id FROM Price_Book_Items__r)
			FROM EUR_CRM_SKU__c
		];
	}

	private static List<EUR_CRM_Size__c> selectBQSs() {
		return [
			SELECT Id
			,   EUR_CRM_PBI_count__c
			,   (SELECT Id FROM Price_Book_Items__r)
			FROM EUR_CRM_Size__c
		];
	}

	private static List<EUR_CRM_POS_Material__c> selectPOSMs() {
		return [
			SELECT Id
			,   EUR_CRM_PBI_count__c
			,   (SELECT Id FROM Price_Book_Items__r)
			FROM EUR_CRM_POS_Material__c
		];
	}

}