@IsTest(IsParallel = true)
private class EUR_CRM_VolumeTrackerPeriodBatchTest {
	private static final String ACC_FI_RT = 'EUR_FI_Direct_On_Trade';
	private static final String CONTRACT_FI_RT = 'EUR_FI_Independent_Contract';
	private static final String VT_FI_RT = 'EUR_FI_Volume_Tracker';
	private static final String VTLI_FI_RT = 'EUR_FI_Volume_Tracker_Line_Item';
	private static final String VTP_FI_RT = 'EUR_FI_Volume_Tracker_Period';
	private static final String VTPI_FI_RT = 'EUR_FI_VTPI_Record_Type';

		private static final Map<String, String> VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE = new Map<String, String>{
		'FI' => 'EUR_FI_VTPI_Record_Type'
	,	'SE' => 'EUR_SE_Volume_Tracker_Period_Item'
	,	'DE' => 'EUR_DE_VTPI_Record_Type'
	,	'DK' => 'EUR_DK_VTPI_Record_Type'
	,	'GB' => 'EUR_GB_VTPI_Record_Type'
	,	'NL' => 'EUR_NL_Volume_Tracker_Period_Item'
	};

	private static final Integer COUNT_OF_RECORDS = 5;

	private static void initCMT() {
		EUR_CRM_RecordTypeHelper_v2.rtMapsForTest.addALL(
			EUR_CRM_RecordTypeHelper_v2.makeRtMapsForTest('EUR_CRM_VolumeTrackerPeriodBatch', 'VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE', VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE));
	}

	@IsTest
	static void validCountryCode_VtpWithVtliLookup_CreateVtpi_PositiveTest() {
		initCMT();

		EUR_CRM_Account__c account = makeAccount(ACC_FI_RT);
		insert account;

		EUR_CRM_Contract__c contract = makeContract(account.Id, CONTRACT_FI_RT);
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
		insert vt;

		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli = makeVTLI(vt.Id, VTLI_FI_RT);
		vtli.EUR_CRM_External_ID__c = 'VTLI_EXT_ID';
		insert vtli;

		EUR_CRM_Volume_Tracker_Period__c vtp = makeVTP(vt.Id, vtli.Id, VTP_FI_RT);
		vtp.EUR_CRM_Volume_by_Bottles__c = 666;
		insert vtp;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerPeriodBatch('FI'));
		Test.stopTest();

		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpis = selectVTPIs();
		System.assertEquals(1, vtpis.size());
		System.assertEquals(vtli.Id, vtpis[0].EUR_CRM_Product__c);
		System.assertEquals(vtp.Id, vtpis[0].EUR_CRM_Volume_Tracker_Period__c);
		System.assertEquals(VTPI_FI_RT, vtpis[0].RecordType.DeveloperName);
		System.assertEquals('VTLI_EXT_ID', vtpis[0].EUR_CRM_External_ID__c);
		System.assertEquals(vtp.EUR_CRM_Volume_by_Bottles__c, vtpis[0].EUR_CRM_Actual_Volume__c);
	}

	@IsTest
	static void validCountryCode_VtpWithoutVtliLookup_NoCreateVtpi_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c account = makeAccount(ACC_FI_RT);
		insert account;

		EUR_CRM_Contract__c contract = makeContract(account.Id, CONTRACT_FI_RT);
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
		insert vt;

		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli = makeVTLI(vt.Id, VTLI_FI_RT);
		insert vtli;

		EUR_CRM_Volume_Tracker_Period__c vtp = makeVTP(vt.Id, null, VTP_FI_RT);
		insert vtp;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerPeriodBatch('FI'));
		Test.stopTest();

		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpis = selectVTPIs();
		System.assertEquals(0, vtpis.size());
	}

	@IsTest
	static void invalidCountryCode_VtpWithVtliLookup_NoCreateVtpi_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c account = makeAccount(ACC_FI_RT);
		insert account;

		EUR_CRM_Contract__c contract = makeContract(account.Id, CONTRACT_FI_RT);
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
		insert vt;

		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli = makeVTLI(vt.Id, VTLI_FI_RT);
		insert vtli;

		EUR_CRM_Volume_Tracker_Period__c vtp = makeVTP(vt.Id, vtli.Id, VTP_FI_RT);
		insert vtp;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerPeriodBatch('SE'));
		Test.stopTest();

		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpis = selectVTPIs();
		System.assertEquals(0, vtpis.size());
	}



	@IsTest
	static void validCountryCode_VtpWithVtliLookup_CreateVtpi_MassPositiveTest() {
		initCMT();

		EUR_CRM_Account__c account = makeAccount(ACC_FI_RT);
		insert account;

		EUR_CRM_Contract__c contract = makeContract(account.Id, CONTRACT_FI_RT);
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
		insert vt;

		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis = makeVTLIs(vt.Id, VTLI_FI_RT);
		insert vtlis;

		List<EUR_CRM_Volume_Tracker_Period__c> vtps = makeVTPs(vt.Id, vtlis, VTP_FI_RT);
		insert vtps;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerPeriodBatch('FI'));
		Test.stopTest();

		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpis = selectVTPIs();
		System.assertEquals(5, vtpis.size());
		for (EUR_CRM_Volume_Tracker_Period_Item__c vtpi : vtpis) {
			System.assertNotEquals(null, vtpi.EUR_CRM_Product__c);
			System.assertNotEquals(null, vtpi.EUR_CRM_Volume_Tracker_Period__c);
			System.assertEquals(VTPI_FI_RT, vtpi.RecordType.DeveloperName);
		}
	}

	@IsTest
	static void validCountryCode_VtpiAlreadyExist_NoCreateVtpi_NegativeTest() {
		initCMT();

		EUR_CRM_Account__c account = makeAccount(ACC_FI_RT);
		insert account;

		EUR_CRM_Contract__c contract = makeContract(account.Id, CONTRACT_FI_RT);
		insert contract;

		EUR_CRM_GB_Volume_Tracker__c vt = makeVT(contract.Id, VT_FI_RT);
		insert vt;

		EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli = makeVTLI(vt.Id, VTLI_FI_RT);
		vtli.EUR_CRM_External_ID__c = 'VTLI_EXT_ID';
		insert vtli;

		EUR_CRM_Volume_Tracker_Period__c vtp = makeVTP(vt.Id, vtli.Id, VTP_FI_RT);
		vtp.EUR_CRM_Volume_by_Bottles__c = 666;
		insert vtp;

		EUR_CRM_Volume_Tracker_Period_Item__c vtpi = makeVTPI(vtp.Id, vtli.Id, VTPI_FI_RT);
		insert vtpi;

		Test.startTest();
		Database.executeBatch(new EUR_CRM_VolumeTrackerPeriodBatch('FI'));
		Test.stopTest();

		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpis = selectVTPIs();
		System.assertEquals(1, vtpis.size());
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

	private static EUR_CRM_GB_Volume_Tracker_Line_Item__c makeVTLI(Id vtId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_GB_Volume_Tracker_Line_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_GB_Volume_Tracker_Line_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Volume_Tracker__c = vtId
		);
	}

	private static List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> makeVTLIs(Id vtId, String rt) {
		List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlisToInsert = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
		for (Integer i = 0; i < COUNT_OF_RECORDS; i++) {
			vtlisToInsert.add(makeVTLI(vtId, rt));
		}
		return vtlisToInsert;
	}

	private static EUR_CRM_Volume_Tracker_Period__c makeVTP(Id vtId, Id vtliId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Volume_Tracker_Period__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Volume_Tracker_Period__c(
			RecordTypeId = rtId
		,	EUR_CRM_Volume_Tracker_EU__c = vtId
		,	EUR_CRM_Volume_Tracker_Line_Item__c = vtliId
		);
	}

	private static List<EUR_CRM_Volume_Tracker_Period__c> makeVTPs(Id vtId, List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> vtlis, String rt) {
		List<EUR_CRM_Volume_Tracker_Period__c> vtpiToInsert = new List<EUR_CRM_Volume_Tracker_Period__c>();
		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vtlis) {
			vtpiToInsert.add(makeVTP(vtId, vtli.Id, rt));
		}
		return vtpiToInsert;
	}

	private static EUR_CRM_Volume_Tracker_Period_Item__c makeVTPI (Id vtpId, Id vtliId, String rt) {
		Id rtId = Schema.SObjectType.EUR_CRM_Volume_Tracker_Period_Item__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
		return new EUR_CRM_Volume_Tracker_Period_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Volume_Tracker_Period__c = vtpId
		,	EUR_CRM_Product__c = vtliId
		);
	}


	private static List<EUR_CRM_Volume_Tracker_Period_Item__c> selectVTPIs() {
		return [
			SELECT Id
			,	EUR_CRM_Product__c
			,	EUR_CRM_Volume_Tracker_Period__c
			,	RecordType.DeveloperName
			,	EUR_CRM_Actual_Volume__c
			,	EUR_CRM_External_ID__c
			FROM EUR_CRM_Volume_Tracker_Period_Item__c
		];
	}
}