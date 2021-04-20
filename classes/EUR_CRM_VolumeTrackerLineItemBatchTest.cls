/*
VT - EUR_CRM_GB_Volume_Tracker__c
VTLI - EUR_CRM_GB_Volume_Tracker_Line_Item__c
B - EUR_CRM_Brand__c (Brand (EU))
BQ - EUR_CRM_Quality__c (Brand-Quality (EU))
BQS - EUR_CRM_Size__c (Brand-Quality-Size (EU))
SKU - EUR_CRM_SKU__c (SKU (EU))
CAI - EUR_CRM_Contract_Activity_Item__c (Contract Activity Item (EU))
CPI - EUR_CRM_Contract_Product_Item__c (Contract Product Item (EU))
MT - EUR_CRM_Mechanic_Type__c (Mechanic Type (EU))
*/

@IsTest(IsParallel = true)
private class EUR_CRM_VolumeTrackerLineItemBatchTest {

    private static final String ACC_FI_RT = 'EUR_FI_Direct_On_Trade';
    private static final String CONTRACT_FI_RT = 'EUR_FI_Independent_Contract';
    private static final String VT_FI_RT = 'EUR_FI_Volume_Tracker';
    private static final String VTLI_FI_RT = 'EUR_FI_Volume_Tracker_Line_Item';
    private static final String CAI_FI_RT = 'EUR_FI_Contract_Activity_Item';
    private static final String CPI_FI_RT = 'EUR_FI_Contract_Product_Item';
    private static final String MT_FI_RT = 'EUR_FI_Mechanic_Type';

    private static List<String> fiMtNames = new List<String>{
            'Marketing Activity Wines'
            , 'Education'
            , 'Free stock'
            , 'Pouring Refund Wines'
            , 'Selection Brands Wines'
            , 'Marketing Activity Spirits'
            , 'Selection Brands Spirits'
            , 'Trips'
            , 'Pouring Refund Spirits'
    };

    @TestSetup
    static void setup() {
        EUR_CRM_Account__c acc = makeAccount(ACC_FI_RT);
        insert acc;

        EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_FI_RT);
        insert contract;

        EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
        insert vt;

        EUR_CRM_Brand__c b = makeB('B_EXT_ID');
        insert b;

        EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_EXT_ID');
        insert bq;

        EUR_CRM_Size__c bqs = makeBQS(bq.Id, 'BQS_EXT_ID');
        insert bqs;

        EUR_CRM_SKU__c sku = makeSKU(bqs.Id, 'SKU_EXT_ID');
        insert sku;

        EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, 'Pouring Refund Spirits', VTLI_FI_RT);
        vtli1.EUR_CRM_Brand__c = b.Id;
        vtli1.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
        EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, 'Pouring Refund Spirits', VTLI_FI_RT);
        vtli2.EUR_CRM_Brand_Quality__c = bq.Id;
        vtli2.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
        EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli3 = makeVTLI(vt.Id, 'Pouring Refund Spirits', VTLI_FI_RT);
        vtli3.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
        EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli4 = makeVTLI(vt.Id, 'Pouring Refund Spirits', VTLI_FI_RT);
        vtli4.EUR_CRM_SKU__c = sku.Id;
        vtli4.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
        insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{
                vtli1, vtli2, vtli3, vtli4
        };

        EUR_CRM_Mechanic_Type__c mt1 = makeMT(MT_FI_RT, 'Pouring Refund Spirits');
        insert mt1;

        EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, CAI_FI_RT, mt1.Id);
        insert cai;

        EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'B_EXT_ID', CPI_FI_RT, null);
        EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'BQ_EXT_ID', CPI_FI_RT, bqs.Id);
        EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai.Id, 'BQS_EXT_ID', CPI_FI_RT, null);
        EUR_CRM_Contract_Product_Item__c cpi4 = makeCPI(cai.Id, 'SKU_EXT_ID', CPI_FI_RT, null);
        insert new List<EUR_CRM_Contract_Product_Item__c>{
                cpi1, cpi2, cpi3, cpi4
        };
    }

    @IsTest
    static void testPositiveUpdateVolumeTrackerLineItem() {
        Test.startTest();

		Database.executeBatch(new EUR_CRM_VolumeTrackerLineItemBatch());

		Test.stopTest();
    }

//	@IsTest
//	private static void oneVtliAndOneCai_sameMtNames_ContractProductUpdated_PositiveTest() {
//		EUR_CRM_Account__c acc = makeAccount(ACC_FI_RT);
//		insert acc;
//
//		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_FI_RT);
//		insert contract;
//
//		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
//		insert vt;
//
//		EUR_CRM_Brand__c b = makeB('B_EXT_ID');
//		insert b;
//
//		EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_EXT_ID');
//		insert bq;
//
//		EUR_CRM_Size__c bqs = makeBQS(bq.Id, 'BQS_EXT_ID');
//		insert bqs;
//
//		EUR_CRM_SKU__c sku = makeSKU(bqs.Id, 'SKU_EXT_ID');
//		insert sku;
//
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli1.EUR_CRM_Brand__c = b.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli2.EUR_CRM_Brand_Quality__c = bq.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli3 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli3.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli4 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli4.EUR_CRM_SKU__c = sku.Id;
//		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2, vtli3, vtli4 };
//
//		EUR_CRM_Mechanic_Type__c mt1 = makeMT(MT_FI_RT, 'Marketing Activity Wines');
//		insert mt1;
//
//		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, CAI_FI_RT, mt1.Id);
//		insert cai;
//
//		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'B_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'BQ_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai.Id, 'BQS_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi4 = makeCPI(cai.Id, 'SKU_EXT_ID', CPI_FI_RT);
//		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2, cpi3, cpi4 };
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_VolumeTrackerLineItemBatch());
//		Test.stopTest();
//
//		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = selectVTLIs();
//		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAIs();
//		System.assertEquals(4, vtlis.size());
//		System.assertEquals(1, cais.size());
//		System.assertEquals(4, cais[0].Contract_Product_Items__r.size());
//		System.assertEquals('Marketing Activity Wines', cais[0].EUR_CRM_Mechanic_Type__r.Name);
//		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
//			System.assertEquals('Marketing Activity Wines', vtli.EUR_CRM_Mechanic_Type_Name__c);
//			if (vtli.EUR_CRM_Brand__c != null) {
//				System.assertEquals(cpi1.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_Brand_Quality__c != null) {
//				System.assertEquals(cpi2.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_Brand_Quality_Size__c != null) {
//				System.assertEquals(cpi3.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_SKU__c != null) {
//				System.assertEquals(cpi4.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//		}
//	}
//
//	@IsTest
//	private static void oneVtliAndTwoCai_sameMtNames_ContractProductUpdated_PositiveTest() {
//		EUR_CRM_Account__c acc = makeAccount(ACC_FI_RT);
//		insert acc;
//
//		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_FI_RT);
//		insert contract;
//
//		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
//		insert vt;
//
//		EUR_CRM_Brand__c b = makeB('B_EXT_ID');
//		insert b;
//
//		EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_EXT_ID');
//		insert bq;
//
//		EUR_CRM_Size__c bqs = makeBQS(bq.Id, 'BQS_EXT_ID');
//		insert bqs;
//
//		EUR_CRM_SKU__c sku = makeSKU(bqs.Id, 'SKU_EXT_ID');
//		insert sku;
//
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli1.EUR_CRM_Brand__c = b.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli2.EUR_CRM_Brand_Quality__c = bq.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli3 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli3.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli4 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli4.EUR_CRM_SKU__c = sku.Id;
//		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2, vtli3, vtli4 };
//
//		EUR_CRM_Mechanic_Type__c mt1 = makeMT(MT_FI_RT, 'Marketing Activity Wines');
//		EUR_CRM_Mechanic_Type__c mt2 = makeMT(MT_FI_RT, 'Education');
//		insert new List<EUR_CRM_Mechanic_Type__c>{ mt1, mt2 };
//
//		EUR_CRM_Contract_Activity_Item__c cai1 = makeCAI(contract.Id, CAI_FI_RT, mt1.Id);
//		EUR_CRM_Contract_Activity_Item__c cai2 = makeCAI(contract.Id, CAI_FI_RT, mt2.Id);
//		insert new List<EUR_CRM_Contract_Activity_Item__c>{ cai1, cai2 };
//
//		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai1.Id, 'B_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai1.Id, 'BQ_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai1.Id, 'BQS_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi4 = makeCPI(cai1.Id, 'SKU_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi5 = makeCPI(cai2.Id, 'B_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi6 = makeCPI(cai2.Id, 'BQ_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi7 = makeCPI(cai2.Id, 'BQS_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi8 = makeCPI(cai2.Id, 'SKU_EXT_ID_WRONG', CPI_FI_RT);
//		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2, cpi3, cpi4, cpi5, cpi6, cpi7, cpi8 };
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_VolumeTrackerLineItemBatch('EUR_FI_Volume_Tracker_Line_Item'));
//		Test.stopTest();
//
//		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = selectVTLIs();
//		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAIs();
//		System.assertEquals(4, vtlis.size());
//		System.assertEquals(2, cais.size());
//		System.assertEquals(4, cais[0].Contract_Product_Items__r.size());
//		System.assertEquals(4, cais[1].Contract_Product_Items__r.size());
//		System.assertEquals('Education', cais[0].EUR_CRM_Mechanic_Type__r.Name);
//		System.assertEquals('Marketing Activity Wines', cais[1].EUR_CRM_Mechanic_Type__r.Name);
//		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
//			System.assertEquals('Marketing Activity Wines', vtli.EUR_CRM_Mechanic_Type_Name__c);
//			if (vtli.EUR_CRM_Brand__c != null) {
//				System.assertEquals(cpi1.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_Brand_Quality__c != null) {
//				System.assertEquals(cpi2.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_Brand_Quality_Size__c != null) {
//				System.assertEquals(cpi3.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_SKU__c != null) {
//				System.assertEquals(cpi4.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//		}
//	}
//
//	@IsTest
//	private static void oneVtliAndOneCai_diffMtNames_ContractProductNotUpdated_NegativeTest() {
//		EUR_CRM_Account__c acc = makeAccount(ACC_FI_RT);
//		insert acc;
//
//		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_FI_RT);
//		insert contract;
//
//		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
//		insert vt;
//
//		EUR_CRM_Brand__c b = makeB('B_EXT_ID');
//		insert b;
//
//		EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_EXT_ID');
//		insert bq;
//
//		EUR_CRM_Size__c bqs = makeBQS(bq.Id, 'BQS_EXT_ID');
//		insert bqs;
//
//		EUR_CRM_SKU__c sku = makeSKU(bqs.Id, 'SKU_EXT_ID');
//		insert sku;
//
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli1.EUR_CRM_Brand__c = b.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli2.EUR_CRM_Brand_Quality__c = bq.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli3 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli3.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli4 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli4.EUR_CRM_SKU__c = sku.Id;
//		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2, vtli3, vtli4 };
//
//		EUR_CRM_Mechanic_Type__c mt1 = makeMT(MT_FI_RT, 'Education');
//		insert mt1;
//
//		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, CAI_FI_RT, mt1.Id);
//		insert cai;
//
//		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'B_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'BQ_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai.Id, 'BQS_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi4 = makeCPI(cai.Id, 'SKU_EXT_ID', CPI_FI_RT);
//		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2, cpi3, cpi4 };
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_VolumeTrackerLineItemBatch('EUR_FI_Volume_Tracker_Line_Item'));
//		Test.stopTest();
//
//		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = selectVTLIs();
//		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAIs();
//		System.assertEquals(4, vtlis.size());
//		System.assertEquals(1, cais.size());
//		System.assertEquals(4, cais[0].Contract_Product_Items__r.size());
//		System.assertEquals('Education', cais[0].EUR_CRM_Mechanic_Type__r.Name);
//		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
//			System.assertEquals('Marketing Activity Wines', vtli.EUR_CRM_Mechanic_Type_Name__c);
//			System.assertEquals(null, vtli.EUR_CRM_Contract_Product__c);
//		}
//	}
//
//	@IsTest
//	private static void oneVtliAndOneCai_sameMtNames_diffExtIds_ContractProductNotUpdated_NegativeTest() {
//		EUR_CRM_Account__c acc = makeAccount(ACC_FI_RT);
//		insert acc;
//
//		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_FI_RT);
//		insert contract;
//
//		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
//		insert vt;
//
//		EUR_CRM_Brand__c b = makeB('B_EXT_ID');
//		insert b;
//
//		EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_EXT_ID');
//		insert bq;
//
//		EUR_CRM_Size__c bqs = makeBQS(bq.Id, 'BQS_EXT_ID');
//		insert bqs;
//
//		EUR_CRM_SKU__c sku = makeSKU(bqs.Id, 'SKU_EXT_ID');
//		insert sku;
//
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli1.EUR_CRM_Brand__c = b.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli2.EUR_CRM_Brand_Quality__c = bq.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli3 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli3.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli4 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli4.EUR_CRM_SKU__c = sku.Id;
//		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2, vtli3, vtli4 };
//
//		EUR_CRM_Mechanic_Type__c mt1 = makeMT(MT_FI_RT, 'Marketing Activity Wines');
//		insert mt1;
//
//		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, CAI_FI_RT, mt1.Id);
//		insert cai;
//
//		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'B_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'BQ_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai.Id, 'BQS_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi4 = makeCPI(cai.Id, 'SKU_EXT_ID_WRONG', CPI_FI_RT);
//		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2, cpi3, cpi4 };
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_VolumeTrackerLineItemBatch('EUR_FI_Volume_Tracker_Line_Item'));
//		Test.stopTest();
//
//		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = selectVTLIs();
//		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAIs();
//		System.assertEquals(4, vtlis.size());
//		System.assertEquals(1, cais.size());
//		System.assertEquals(4, cais[0].Contract_Product_Items__r.size());
//		System.assertEquals('Marketing Activity Wines', cais[0].EUR_CRM_Mechanic_Type__r.Name);
//		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
//			System.assertEquals('Marketing Activity Wines', vtli.EUR_CRM_Mechanic_Type_Name__c);
//			System.assertEquals(null, vtli.EUR_CRM_Contract_Product__c);
//		}
//	}
//
//	@IsTest
//	private static void oneVtliAndOneCaiWithManyCpis_sameMtNames_ContractProductUpdated_PositiveTest() {
//		EUR_CRM_Account__c acc = makeAccount(ACC_FI_RT);
//		insert acc;
//
//		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_FI_RT);
//		insert contract;
//
//		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
//		insert vt;
//
//		EUR_CRM_Brand__c b = makeB('B_EXT_ID');
//		insert b;
//
//		EUR_CRM_Quality__c bq = makeBQ(b.Id, 'BQ_EXT_ID');
//		insert bq;
//
//		EUR_CRM_Size__c bqs = makeBQS(bq.Id, 'BQS_EXT_ID');
//		insert bqs;
//
//		EUR_CRM_SKU__c sku = makeSKU(bqs.Id, 'SKU_EXT_ID');
//		insert sku;
//
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli1.EUR_CRM_Brand__c = b.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli2.EUR_CRM_Brand_Quality__c = bq.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli3 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli3.EUR_CRM_Brand_Quality_Size__c = bqs.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli4 = makeVTLI(vt.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli4.EUR_CRM_SKU__c = sku.Id;
//		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2, vtli3, vtli4 };
//
//		EUR_CRM_Mechanic_Type__c mt1 = makeMT(MT_FI_RT, 'Marketing Activity Wines');
//		insert mt1;
//
//		EUR_CRM_Contract_Activity_Item__c cai = makeCAI(contract.Id, CAI_FI_RT, mt1.Id);
//		insert cai;
//
//		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai.Id, 'B_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai.Id, 'BQ_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai.Id, 'BQS_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi4 = makeCPI(cai.Id, 'SKU_EXT_ID', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi5 = makeCPI(cai.Id, 'B_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi6 = makeCPI(cai.Id, 'BQ_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi7 = makeCPI(cai.Id, 'BQS_EXT_ID_WRONG', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi8 = makeCPI(cai.Id, 'SKU_EXT_ID_WRONG', CPI_FI_RT);
//		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2, cpi3, cpi4, cpi5, cpi6, cpi7, cpi8 };
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_VolumeTrackerLineItemBatch('EUR_FI_Volume_Tracker_Line_Item'));
//		Test.stopTest();
//
//		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = selectVTLIs();
//		List<EUR_CRM_Contract_Activity_Item__c> cais = selectCAIs();
//		System.assertEquals(4, vtlis.size());
//		System.assertEquals(1, cais.size());
//		System.assertEquals(8, cais[0].Contract_Product_Items__r.size());
//		System.assertEquals('Marketing Activity Wines', cais[0].EUR_CRM_Mechanic_Type__r.Name);
//		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
//			System.assertEquals('Marketing Activity Wines', vtli.EUR_CRM_Mechanic_Type_Name__c);
//			if (vtli.EUR_CRM_Brand__c != null) {
//				System.assertEquals(cpi1.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_Brand_Quality__c != null) {
//				System.assertEquals(cpi2.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_Brand_Quality_Size__c != null) {
//				System.assertEquals(cpi3.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//			if (vtli.EUR_CRM_SKU__c != null) {
//				System.assertEquals(cpi4.Id, vtli.EUR_CRM_Contract_Product__c);
//			}
//		}
//	}
//
//	/* ========================================================= */
//	/*      Mass update test
//	/* ========================================================= */
//	@IsTest
//	private static void massUpdate_PositiveTest() {
//		EUR_CRM_Account__c account = makeAccount(ACC_FI_RT);
//		insert account;
//
//		EUR_CRM_Contract__c contr1 = makeContract(account.Id, CONTRACT_FI_RT);
//		EUR_CRM_Contract__c contr2 = makeContract(account.Id, CONTRACT_FI_RT);
//		insert new List<EUR_CRM_Contract__c>{ contr1, contr2 };
//
//		EUR_CRM_GB_Volume_Tracker__c vt1 = makeVT(contr1.Id, VT_FI_RT);
//		EUR_CRM_GB_Volume_Tracker__c vt2 = makeVT(contr1.Id, VT_FI_RT);
//		insert new List<EUR_CRM_GB_Volume_Tracker__c>{ vt1, vt2 };
//
//		EUR_CRM_Brand__c b1 = makeB('B_EXT_ID_1');
//		EUR_CRM_Brand__c b2 = makeB('B_EXT_ID_2');
//		List<EUR_CRM_Brand__c> bs = new List<EUR_CRM_Brand__c>{ b1, b2 };
//		insert bs;
//
//		EUR_CRM_Quality__c bq1 = makeBQ(b1.Id, 'BQ_EXT_ID_1');
//		EUR_CRM_Quality__c bq2 = makeBQ(b2.Id, 'BQ_EXT_ID_2');
//		List<EUR_CRM_Quality__c> bqs = new List<EUR_CRM_Quality__c>{ bq1, bq2 };
//		insert bqs;
//
//		EUR_CRM_Size__c bqs1 = makeBQS(bq1.Id, 'BQS_EXT_ID_1');
//		EUR_CRM_Size__c bqs2 = makeBQS(bq2.Id, 'BQS_EXT_ID_2');
//		List<EUR_CRM_Size__c> bqss = new List<EUR_CRM_Size__c>{ bqs1, bqs2 };
//		insert bqss;
//
//		EUR_CRM_SKU__c sku1 = makeSKU(bqs1.Id, 'SKU_EXT_ID_1');
//		EUR_CRM_SKU__c sku2 = makeSKU(bqs2.Id, 'SKU_EXT_ID_2');
//		List<EUR_CRM_SKU__c> skus = new List<EUR_CRM_SKU__c>{ sku1, sku2 };
//		insert skus;
//
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt1.Id, 'Marketing Activity Wines', VTLI_FI_RT);
//		vtli1.EUR_CRM_Brand__c = b1.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt1.Id, 'Education', VTLI_FI_RT);
//		vtli2.EUR_CRM_Brand_Quality__c = bq1.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli3 = makeVTLI(vt1.Id, 'Free stock', VTLI_FI_RT);
//		vtli3.EUR_CRM_Brand_Quality_Size__c = bqs1.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli4 = makeVTLI(vt1.Id, 'Pouring Refund Wines', VTLI_FI_RT);
//		vtli4.EUR_CRM_SKU__c = sku1.Id;
//
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli5 = makeVTLI(vt1.Id, 'Selection Brands Wines', VTLI_FI_RT);
//		vtli5.EUR_CRM_Brand__c = b2.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli6 = makeVTLI(vt1.Id, 'Marketing Activity Spirits', VTLI_FI_RT);
//		vtli6.EUR_CRM_Brand_Quality__c = bq2.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli7 = makeVTLI(vt1.Id, 'Selection Brands Spirits', VTLI_FI_RT);
//		vtli7.EUR_CRM_Brand_Quality_Size__c = bqs2.Id;
//		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli8 = makeVTLI(vt1.Id, 'Trips', VTLI_FI_RT);
//		vtli8.EUR_CRM_SKU__c = sku2.Id;
//		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2, vtli3, vtli4, vtli5, vtli6, vtli7, vtli8 };
//
//		EUR_CRM_Mechanic_Type__c mt1 = makeMT(MT_FI_RT, 'Marketing Activity Wines');
//		EUR_CRM_Mechanic_Type__c mt2 = makeMT(MT_FI_RT, 'Education');
//		EUR_CRM_Mechanic_Type__c mt3 = makeMT(MT_FI_RT, 'Free stock');
//		EUR_CRM_Mechanic_Type__c mt4 = makeMT(MT_FI_RT, 'Pouring Refund Wines');
//		EUR_CRM_Mechanic_Type__c mt5 = makeMT(MT_FI_RT, 'Selection Brands Wines');
//		EUR_CRM_Mechanic_Type__c mt6 = makeMT(MT_FI_RT, 'Marketing Activity Spirits');
//		EUR_CRM_Mechanic_Type__c mt7 = makeMT(MT_FI_RT, 'Selection Brands Spirits');
//		EUR_CRM_Mechanic_Type__c mt8 = makeMT(MT_FI_RT, 'Trips');
//		insert new List<EUR_CRM_Mechanic_Type__c>{ mt1, mt2, mt3, mt4, mt5, mt6, mt7, mt8 };
//
//		EUR_CRM_Contract_Activity_Item__c cai1 = makeCAI(contr1.Id, CAI_FI_RT, mt1.Id);
//		EUR_CRM_Contract_Activity_Item__c cai2 = makeCAI(contr1.Id, CAI_FI_RT, mt2.Id);
//		EUR_CRM_Contract_Activity_Item__c cai3 = makeCAI(contr1.Id, CAI_FI_RT, mt3.Id);
//		EUR_CRM_Contract_Activity_Item__c cai4 = makeCAI(contr1.Id, CAI_FI_RT, mt4.Id);
//
//		EUR_CRM_Contract_Activity_Item__c cai5 = makeCAI(contr2.Id, CAI_FI_RT, mt5.Id);
//		EUR_CRM_Contract_Activity_Item__c cai6 = makeCAI(contr2.Id, CAI_FI_RT, mt6.Id);
//		EUR_CRM_Contract_Activity_Item__c cai7 = makeCAI(contr2.Id, CAI_FI_RT, mt7.Id);
//		EUR_CRM_Contract_Activity_Item__c cai8 = makeCAI(contr2.Id, CAI_FI_RT, mt8.Id);
//
//		insert new List<EUR_CRM_Contract_Activity_Item__c>{
//			cai1, cai2, cai3, cai4, cai5, cai6, cai7, cai8
//		};
//
//		EUR_CRM_Contract_Product_Item__c cpi1 = makeCPI(cai1.Id, 'B_EXT_ID_1', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi2 = makeCPI(cai2.Id, 'BQ_EXT_ID_1', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi3 = makeCPI(cai3.Id, 'BQS_EXT_ID_1', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi4 = makeCPI(cai4.Id, 'SKU_EXT_ID_1', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi5 = makeCPI(cai5.Id, 'B_EXT_ID_2', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi6 = makeCPI(cai6.Id, 'BQ_EXT_ID_2', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi7 = makeCPI(cai7.Id, 'BQS_EXT_ID_2', CPI_FI_RT);
//		EUR_CRM_Contract_Product_Item__c cpi8 = makeCPI(cai8.Id, 'SKU_EXT_ID_2', CPI_FI_RT);
//		insert new List<EUR_CRM_Contract_Product_Item__c>{ cpi1, cpi2, cpi3, cpi4, cpi5, cpi6, cpi7, cpi8 };
//
//		Test.startTest();
//		Database.executeBatch(new EUR_CRM_VolumeTrackerLineItemBatch('EUR_FI_Volume_Tracker_Line_Item'));
//		Test.stopTest();
//
//		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = selectVTLIs();
//		List<EUR_CRM_Contract_Activity_Item__c> caisInserted = selectCAIs();
//		List<EUR_CRM_Contract_Product_Item__c> cpisInserted = selectCPIs();
//		System.assertEquals(8, vtlis.size());
//		System.assertEquals(8, caisInserted.size());
//		System.assertEquals(8, cpisInserted.size());
//
//		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Marketing Activity Wines') {
//				vtli.EUR_CRM_Contract_Product__c = cpi1.Id;
//			}
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Education') {
//				vtli.EUR_CRM_Contract_Product__c = cpi2.Id;
//			}
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Free stock') {
//				vtli.EUR_CRM_Contract_Product__c = cpi3.Id;
//			}
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Pouring Refund Wines') {
//				vtli.EUR_CRM_Contract_Product__c = cpi4.Id;
//			}
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Selection Brands Wines') {
//				vtli.EUR_CRM_Contract_Product__c = cpi5.Id;
//			}
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Marketing Activity Spirits') {
//				vtli.EUR_CRM_Contract_Product__c = cpi6.Id;
//			}
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Selection Brands Spirits') {
//				vtli.EUR_CRM_Contract_Product__c = cpi7.Id;
//			}
//			if (vtli.EUR_CRM_Mechanic_Type_Name__c == 'Trips') {
//				vtli.EUR_CRM_Contract_Product__c = cpi8.Id;
//			}
//		}
//	}


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
                Name = 'Account'
                , EUR_CRM_Postal_Code__c = '12345'
                , RecordTypeId = rtId
        );
    }

    private static EUR_CRM_Contract__c makeContract(Id accId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract__c(
                RecordTypeId = rtId
                , EUR_CRM_Account__c = accId
        );
    }

    private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id contractId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract_Activity_Item__c(
                RecordTypeId = rtId
                , EUR_CRM_Contract__c = contractId
        );
    }

    private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id contractId, String rt, Id mtId) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract_Activity_Item__c(
                RecordTypeId = rtId
                , EUR_CRM_Contract__c = contractId
                , EUR_CRM_Mechanic_Type__c = mtId
        );
    }

    private static EUR_CRM_Mechanic_Type__c makeMT(String rt, String name) {
        Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c .getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Mechanic_Type__c(
                RecordTypeId = rtId
                , Name = name
        );
    }
    private static EUR_CRM_Contract_Product_Item__c makeCPI(Id caiId, String extId, String rt, Id bqs) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract_Product_Item__c(
                RecordTypeId = rtId
                , EUR_CRM_Contract_Activity_Item__c = caiId
                , EUR_CRM_External_ID__c = extId
                , EUR_CRM_Brand_Quality_Size__c = bqs
        );
    }

    private static EUR_CRM_GB_Volume_Tracker__c makeVT(Id contractId, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_GB_Volume_Tracker__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_GB_Volume_Tracker__c(
                RecordTypeId = rtId
                , EUR_CRM_Contract__c = contractId
        );
    }

    private static EUR_CRM_GB_Volume_Tracker_Line_Item__c makeVTLI(Id vtId, String mtName, String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_GB_Volume_Tracker_Line_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_GB_Volume_Tracker_Line_Item__c(
                RecordTypeId = rtId
                , EUR_CRM_Volume_Tracker__c = vtId
                , EUR_CRM_Mechanic_Type_Name__c = mtName
        );
    }

    private static EUR_CRM_Brand__c makeB(String extId) {
        return new EUR_CRM_Brand__c(
                EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_Quality__c makeBQ(Id bId, String extId) {
        return new EUR_CRM_Quality__c(
                EUR_CRM_Brand__c = bId
                , EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_Size__c makeBQS(Id bqId, String extId) {
        return new EUR_CRM_Size__c(
                EUR_CRM_Brand_Quality__c = bqId
                , EUR_CRM_External_ID__c = extId
        );
    }

    private static EUR_CRM_SKU__c makeSKU(Id bqsId, String extId) {
        return new EUR_CRM_SKU__c(
                EUR_CRM_Brand_Quality_Size__c = bqsId
                , EUR_CRM_External_ID__c = extId
        );
    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> selectVTLIs() {
        return [
                SELECT Id
                        , EUR_CRM_Contract_Product__c
                        , EUR_CRM_Mechanic_Type_Name__c
                        , EUR_CRM_Brand__r.EUR_CRM_External_ID__c
                        , EUR_CRM_Brand_Quality__r.EUR_CRM_External_ID__c
                        , EUR_CRM_Brand_Quality_Size__r.EUR_CRM_External_ID__c
                        , EUR_CRM_SKU__r.EUR_CRM_External_ID__c
                FROM EUR_CRM_GB_Volume_Tracker_Line_Item__c
        ];
    }

    private static List<EUR_CRM_Contract_Product_Item__c> selectCPIs() {
        return [
                SELECT Id
                        , EUR_CRM_External_ID__c
                FROM EUR_CRM_Contract_Product_Item__c
        ];
    }

    private static List<EUR_CRM_Contract_Activity_Item__c> selectCAIs() {
        return [
                SELECT Id
                        , EUR_CRM_Contract__c
                        , EUR_CRM_Mechanic_Type__r.Name
                        , (
                        SELECT Id
                                , EUR_CRM_External_ID__c
                        FROM Contract_Product_Items__r
                )
                FROM EUR_CRM_Contract_Activity_Item__c
                ORDER BY EUR_CRM_Mechanic_Type_Name__c
        ];
    }
}