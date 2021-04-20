@IsTest(IsParallel = true)
private class EUR_CRM_VolumeTrackerBatchTest {

	private static final String ACC_GB_RT = 'EUR_GB_FS_RTM';
	private static final String CONTRACT_GB_RT = 'EUR_GB_Contract';
	private static final String VT_GB_RT = 'EUR_GB_Volume_Tracker';
	private static final String VTLI_GB_RT = 'EUR_GB_Volume_Tracker_Line_Item';
	private static final Integer COUNT_OF_RECORDS = 5;

	private static final Date START_DATE = Date.newInstance(2018, 1, 1);
	private static final Date END_DATE = Date.today().addMonths(5);

	private static final Map<String, String> VTP_RT_BY_VT_RT = new Map<String, String>{
		'EUR_GB_Volume_Tracker' => 'EUR_GB_Volume_Tracker_Period'
	};

	private static final Map<String, String> VTPI_RT_BY_VT_RT = new Map<String, String>{
		'EUR_GB_Volume_Tracker' => 'EUR_GB_VTPI_Record_Type'
	};

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest('EUR_CRM_VolumeTrackerBatch', 'VTP_RT_BY_VT_RT', VTP_RT_BY_VT_RT));
		EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addAll(EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest('EUR_CRM_VolumeTrackerBatch', 'VTPI_RT_BY_VT_RT', VTPI_RT_BY_VT_RT));
	}

	@IsTest
	private static void GB_simpleNegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount(ACC_GB_RT);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_GB_RT);
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_GB_RT);
		insert vt;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerBatch('EUR_GB_Volume_Tracker'));
		Test.stopTest();

		List<EUR_CRM_GB_Volume_Tracker__c> vts = selectVTs();
		System.assertEquals(1, vts.size());
		System.assertEquals(0, vts[0].Volume_Tracker_Line_Items__r.size());
		System.assertEquals(0, vts[0].Volume_Tracker_Period_EU__r.size());
	}

	@IsTest
	private static void GB_VolumeTracker_ContractIsNotActivated_simplePositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount(ACC_GB_RT);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_GB_RT);
		contract.EUR_CRM_Start_Date__c = START_DATE;
		contract.EUR_CRM_End_Date__c = END_DATE;
		contract.EUR_CRM_Status__c = 'Draft';
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_GB_RT);
		insert vt;

		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, null, VTLI_GB_RT);
		vtli1.EUR_CRM_Confirmed_Contract_to_Date_Volu__c = 666;
		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, null, VTLI_GB_RT);
		vtli2.EUR_CRM_Confirmed_Contract_to_Date_Volu__c = 667;
		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerBatch('EUR_GB_Volume_Tracker'));
		Test.stopTest();

		List<EUR_CRM_GB_Volume_Tracker__c> vts = selectVTs();
		List<EUR_CRM_Volume_Tracker_Period__c> insertedChildren = selectVTPs();
		System.assertEquals(1, vts.size());
		System.assertEquals(2, vts[0].Volume_Tracker_Line_Items__r.size());
		System.assertEquals(1, vts[0].Volume_Tracker_Period_EU__r.size());
		System.assertEquals(START_DATE, vts[0].Volume_Tracker_Period_EU__r[0].EUR_CRM_Start_Date__c);
		System.assertEquals(END_DATE, vts[0].Volume_Tracker_Period_EU__r[0].EUR_CRM_End_Date__c);
		System.assertEquals(1, insertedChildren.size());
		System.assertEquals(2, insertedChildren[0].Volume_Tracker_Period_Items__r.size());
		for (EUR_CRM_Volume_Tracker_Period_Item__c vtpi : insertedChildren[0].Volume_Tracker_Period_Items__r) {
			System.assertEquals('EUR_GB_VTPI_Record_Type', vtpi.RecordType.DeveloperName);
			System.assertNotEquals(null, vtpi.EUR_CRM_Actual_Volume__c);
			System.assertNotEquals(null, vtpi.EUR_CRM_Product__c);
		}

	}

	@IsTest
	private static void GB_VolumeTracker_ContractIsActivated_simplePositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount(ACC_GB_RT);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_GB_RT);
		contract.EUR_CRM_Start_Date__c = START_DATE;
		contract.EUR_CRM_End_Date__c = END_DATE;
		contract.EUR_CRM_Status__c = 'Activated';
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_GB_RT);
		insert vt;

		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, null, VTLI_GB_RT);
		vtli1.EUR_CRM_Confirmed_Contract_to_Date_Volu__c = 666;
		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, null, VTLI_GB_RT);
		vtli2.EUR_CRM_Confirmed_Contract_to_Date_Volu__c = 667;
		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerBatch('EUR_GB_Volume_Tracker'));
		Test.stopTest();

		List<EUR_CRM_GB_Volume_Tracker__c> vts = selectVTs();
		List<EUR_CRM_Volume_Tracker_Period__c> insertedChildren = selectVTPs();
		System.assertEquals(1, vts.size());
		System.assertEquals(2, vts[0].Volume_Tracker_Line_Items__r.size());
		System.assertEquals(1, vts[0].Volume_Tracker_Period_EU__r.size());
		System.assertEquals(START_DATE, vts[0].Volume_Tracker_Period_EU__r[0].EUR_CRM_Start_Date__c);
		System.assertEquals(EUR_CRM_VolumeTrackerBatch.CURRENT_DATE, vts[0].Volume_Tracker_Period_EU__r[0].EUR_CRM_End_Date__c);
		System.assertEquals(1, insertedChildren.size());
		System.assertEquals(2, insertedChildren[0].Volume_Tracker_Period_Items__r.size());
		for (EUR_CRM_Volume_Tracker_Period_Item__c vtpi : insertedChildren[0].Volume_Tracker_Period_Items__r) {
			System.assertEquals('EUR_GB_VTPI_Record_Type', vtpi.RecordType.DeveloperName);
			System.assertNotEquals(null, vtpi.EUR_CRM_Actual_Volume__c);
			System.assertNotEquals(null, vtpi.EUR_CRM_Product__c);
		}
	}

	@IsTest
	private static void GB_VolumeTracker_ContractIsActivated_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount(ACC_GB_RT);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_GB_RT);
		contract.EUR_CRM_Start_Date__c = START_DATE;
		contract.EUR_CRM_End_Date__c = END_DATE;
		contract.EUR_CRM_Status__c = 'Activated';
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, 'EUR_FI_Volume_Tracker');
		insert vt;

		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli1 = makeVTLI(vt.Id, null, VTLI_GB_RT);
		vtli1.EUR_CRM_Confirmed_Contract_to_Date_Volu__c = 666;
		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli2 = makeVTLI(vt.Id, null, VTLI_GB_RT);
		vtli2.EUR_CRM_Confirmed_Contract_to_Date_Volu__c = 667;
		insert new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>{ vtli1, vtli2 };

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerBatch('EUR_FI_Volume_Tracker'));
		Test.stopTest();

		List<EUR_CRM_GB_Volume_Tracker__c> vts = selectVTs();
		List<EUR_CRM_Volume_Tracker_Period__c> insertedChildren = selectVTPs();
		System.assertEquals(1, vts.size());
		System.assertEquals(2, vts[0].Volume_Tracker_Line_Items__r.size());
		System.assertEquals(0, vts[0].Volume_Tracker_Period_EU__r.size());
//		System.assertEquals(START_DATE, vts[0].Volume_Tracker_Period_EU__r[0].EUR_CRM_Start_Date__c);
//		System.assertEquals(EUR_CRM_VolumeTrackerBatch.CURRENT_DATE, vts[0].Volume_Tracker_Period_EU__r[0].EUR_CRM_End_Date__c);
		System.assertEquals(0, insertedChildren.size());
//		System.assertEquals(2, insertedChildren[0].Volume_Tracker_Period_Items__r.size());
//		for (EUR_CRM_Volume_Tracker_Period_Item__c vtpi : insertedChildren[0].Volume_Tracker_Period_Items__r) {
//			System.assertEquals('EUR_GB_VTPI_Record_Type', vtpi.RecordType.DeveloperName);
//			System.assertNotEquals(null, vtpi.EUR_CRM_Actual_Volume__c);
//			System.assertNotEquals(null, vtpi.EUR_CRM_Product__c);
//		}
	}

	@IsTest
	private static void GB_massCreatingOfChildren_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c acc = makeAccount(ACC_GB_RT);
		insert acc;

		EUR_CRM_Contract__c contract = makeContract(acc.Id, CONTRACT_GB_RT);
		contract.EUR_CRM_Start_Date__c = START_DATE;
		contract.EUR_CRM_End_Date__c = END_DATE;
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_GB_RT);
		insert vt;

		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = makeVTLIs(vt.Id, VTLI_GB_RT);
		insert vtlis;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerBatch(VT_GB_RT));
		Test.stopTest();

		List<EUR_CRM_Volume_Tracker_Period__c> insertedVTPs = selectVTPs();
		for (EUR_CRM_Volume_Tracker_Period__c vtp : insertedVTPs) {
			System.assertEquals(null, vtp.EUR_CRM_Volume_Tracker_Line_Item__c);
			System.assertEquals(START_DATE, vtp.EUR_CRM_Start_Date__c);
			System.assertEquals(END_DATE, vtp.EUR_CRM_End_Date__c);
			for (Integer i = 0; i < vtp.Volume_Tracker_Period_Items__r.size(); i++) {
				System.assertNotEquals(null, vtp.Volume_Tracker_Period_Items__r.get(i).EUR_CRM_Product__c);
				System.assertEquals('ExtId_' + i, vtp.Volume_Tracker_Period_Items__r.get(i).EUR_CRM_External_ID__c);
				System.assertEquals(i * 100, vtp.Volume_Tracker_Period_Items__r.get(i).EUR_CRM_Actual_Volume__c);
			}
		}
	}



	/* ========================================================= */
	/*     Makers
	/* ========================================================= */
	private static EUR_CRM_Account__c makeAccount(String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Account__c(
			Name = 'Account'
			,   EUR_CRM_Postal_Code__c = '12345'
			,   RecordTypeId = rtId
		);
	}

	private static EUR_CRM_Contract__c makeContract(Id accId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Contract__c(
			RecordTypeId = rtId
			,	EUR_CRM_Account__c = accId
		);
	}

	private static EUR_CRM_GB_Volume_Tracker__c makeVT(Id contractId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_GB_Volume_Tracker__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_GB_Volume_Tracker__c(
			RecordTypeId = rtId
			,	EUR_CRM_Contract__c = contractId
		);
	}

	private static List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> makeVTLIs(Id vtId, String rt) {
		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
		for(Integer i = 0; i < COUNT_OF_RECORDS; i++) {
			EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli = makeVTLI(vtId, null, rt);
			vtli.EUR_CRM_Confirmed_Contract_to_Date_Volu__c = i * 100;
			vtli.EUR_CRM_External_ID__c = 'ExtId_' + i;
			vtlis.add(vtli);
		}
		return vtlis;
	}

	private static EUR_CRM_GB_Volume_Tracker_Line_Item__c makeVTLI(Id vtId, String mtName, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_GB_Volume_Tracker_Line_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_GB_Volume_Tracker_Line_Item__c(
			RecordTypeId = rtId
			,	EUR_CRM_Volume_Tracker__c = vtId
			,	EUR_CRM_Mechanic_Type_Name__c = mtName
		);
	}

//	private static EUR_CRM_Brand__c makeB(String extId) {
//		return new EUR_CRM_Brand__c(
//			EUR_CRM_External_ID__c = extId
//		);
//	}
//
//	private static EUR_CRM_Quality__c makeBQ(Id bId, String extId) {
//		return new EUR_CRM_Quality__c(
//			EUR_CRM_Brand__c = bId
//			,	EUR_CRM_External_ID__c = extId
//		);
//	}
//
//	private static EUR_CRM_Size__c makeBQS(Id bqId, String extId) {
//		return new EUR_CRM_Size__c(
//			EUR_CRM_Brand_Quality__c = bqId
//			,	EUR_CRM_External_ID__c = extId
//		);
//	}
//
//	private static EUR_CRM_SKU__c makeSKU(Id bqsId, String extId) {
//		return new EUR_CRM_SKU__c(
//			EUR_CRM_Brand_Quality_Size__c = bqsId
//			,	EUR_CRM_External_ID__c = extId
//		);
//	}

	//	private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id contractId, String rt) {
//		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
//		return new EUR_CRM_Contract_Activity_Item__c(
//			RecordTypeId = rtId
//			,	EUR_CRM_Contract__c = contractId
//		);
//	}
//
//	private static EUR_CRM_Contract_Activity_Item__c makeCAI(Id contractId, String rt, Id mtId) {
//		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
//		return new EUR_CRM_Contract_Activity_Item__c(
//			RecordTypeId = rtId
//			,	EUR_CRM_Contract__c = contractId
//			,	EUR_CRM_Mechanic_Type__c = mtId
//		);
//	}
//
//	private static EUR_CRM_Mechanic_Type__c makeMT(String rt, String name) {
//		Id rtId = Schema.SObjectType.EUR_CRM_Mechanic_Type__c .getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
//		return new EUR_CRM_Mechanic_Type__c(
//			RecordTypeId = rtId
//			,	Name = name
//		);
//	}
//
//	private static EUR_CRM_Contract_Product_Item__c makeCPI(Id caiId, String extId, String rt) {
//		Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
//		return new EUR_CRM_Contract_Product_Item__c(
//			RecordTypeId = rtId
//			,	EUR_CRM_Contract_Activity_Item__c = caiId
//			,	EUR_CRM_External_ID__c = extId
//		);
//	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private static List<EUR_CRM_GB_Volume_Tracker__c> selectVTs() {
		return [
			SELECT Id
				,	(
				SELECT Id
					,	RecordType.DeveloperName
					,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_Start_Date__c
					,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_End_Date__c
					,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_Status__c
				FROM Volume_Tracker_Line_Items__r
			),	(
				SELECT Id
				,	EUR_CRM_Start_Date__c
				,	EUR_CRM_End_Date__c
				FROM Volume_Tracker_Period_EU__r
			)
			FROM EUR_CRM_GB_Volume_Tracker__c
		];
	}

	private static List<EUR_CRM_Volume_Tracker_Period__c> selectVTPs() {
		return [
			SELECT Id
			,	EUR_CRM_Start_Date__c
			,	EUR_CRM_End_Date__c
			,	EUR_CRM_Volume_Tracker_Line_Item__c
			,	(
				SELECT Id
				,	EUR_CRM_Product__c
				,	EUR_CRM_External_ID__c
				,	EUR_CRM_Actual_Volume__c
				,	RecordType.DeveloperName
				FROM Volume_Tracker_Period_Items__r
			)
			FROM EUR_CRM_Volume_Tracker_Period__c
		];
	}

	private static List<EUR_CRM_Volume_Tracker_Period_Item__c> selectVTPIs() {
		return [
			SELECT Id
			,	EUR_CRM_Product__c
			,	EUR_CRM_External_ID__c
			,	RecordType.DeveloperName
			,	EUR_CRM_Volume_Tracker_Period__c
			FROM EUR_CRM_Volume_Tracker_Period_Item__c
		];
	}

	private static List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> selectVTLIs() {
		return [
			SELECT Id
			,	(
				SELECT
					Id
				FROM Volume_Tracker_Periods__r
			), (
				SELECT Id
				,	EUR_CRM_External_ID__c
				,	EUR_CRM_Actual_Volume__c
				,	EUR_CRM_Volume_Tracker_Period__c
				FROM Volume_Tracker_Period_Items_EU__r
			)

			FROM EUR_CRM_GB_Volume_Tracker_Line_Item__c
		];
	}

//	private static List<EUR_CRM_Contract_Product_Item__c> selectCPIs() {
//		return [
//			SELECT Id
//				,	EUR_CRM_External_ID__c
//			FROM EUR_CRM_Contract_Product_Item__c
//		];
//	}
//
//	private static List<EUR_CRM_Contract_Activity_Item__c> selectCAIs() {
//		return [
//			SELECT Id
//				,	EUR_CRM_Contract__c
//				,	EUR_CRM_Mechanic_Type__r.Name
//				,	(
//				SELECT Id
//					,	EUR_CRM_External_ID__c
//				FROM Contract_Product_Items__r
//			)
//			FROM EUR_CRM_Contract_Activity_Item__c
//			ORDER BY EUR_CRM_Mechanic_Type_Name__c
//		];
//	}
}