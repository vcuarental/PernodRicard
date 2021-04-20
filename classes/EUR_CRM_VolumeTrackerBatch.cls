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

1. EUR_CRM_VolumeTrackerBatch creates VTP and VTPI for VT if VT has no VTPs and has VTLIs.
   This is the logic for GB firstly.
*/

public with sharing class EUR_CRM_VolumeTrackerBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	private static final Map<String, RecordTypeInfo> VTP_RT_INFO_BY_DEVNAME = Schema.SObjectType.EUR_CRM_Volume_Tracker_Period__c.getRecordTypeInfosByDeveloperName();
	private static final Map<String, RecordTypeInfo> VTPI_RT_INFO_BY_DEVNAME = Schema.SObjectType.EUR_CRM_Volume_Tracker_Period_Item__c.getRecordTypeInfosByDeveloperName();

	private static final Map<String, String> VTP_RT_BY_VT_RT = EUR_CRM_RecordTypeHelper_v2.getSettingsMap('EUR_CRM_VolumeTrackerBatch', 'VTP_RT_BY_VT_RT');
	private static final Map<String, String> VTPI_RT_BY_VT_RT = EUR_CRM_RecordTypeHelper_v2.getSettingsMap('EUR_CRM_VolumeTrackerBatch', 'VTPI_RT_BY_VT_RT');

	private static final String ACTIVATED = 'Activated';
	@TestVisible private static final Date CURRENT_DATE = Date.today();

//	private static final Map<String, String> VTP_RT_BY_VT_RT = new Map<String, String>{
//	,	'EUR_GB_Volume_Tracker' => 'EUR_GB_Volume_Tracker_Period'
//	};
//
//	private static final Map<String, String> VTPI_RT_BY_VT_RT = new Map<String, String>{
//	,	'EUR_GB_Volume_Tracker' => 'EUR_GB_VTPI_Record_Type'
//	};

	private String vtRt;

	public EUR_CRM_VolumeTrackerBatch(String vtRt) {
		this.vtRt = vtRt == null ? 'EUR_GB_Volume_Tracker' : vtRt;
	}

	public EUR_CRM_VolumeTrackerBatch() {
		this.vtRt = 'EUR_GB_Volume_Tracker';
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
			,	RecordType.DeveloperName
			,	EUR_CRM_Contract__r.EUR_CRM_End_Date__c
			,	EUR_CRM_Contract__r.EUR_CRM_Start_Date__c
			,	EUR_CRM_Contract__r.EUR_CRM_Status__c
			,	(
				SELECT Id
				,	RecordType.DeveloperName
				,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_Start_Date__c
				,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_End_Date__c
				,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_Status__c
				,	EUR_CRM_Confirmed_Contract_to_Date_Volu__c
				FROM Volume_Tracker_Line_Items__r
			),	(
				SELECT Id
				,	EUR_CRM_Start_Date__c
				,	EUR_CRM_End_Date__c
				FROM Volume_Tracker_Period_EU__r
			)
			FROM EUR_CRM_GB_Volume_Tracker__c
			WHERE RecordType.DeveloperName = :this.vtRt
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_GB_Volume_Tracker__c> vts) {
		this.createVtChildrenForGB(vts);

		this.finish(bc);
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private void createVtChildrenForGB(List<EUR_CRM_GB_Volume_Tracker__c> vts) {
		List<EUR_CRM_GB_Volume_Tracker__c> vtsToCreateChildren = this.getVTsToCreateChildrenForGB(vts);
		System.debug('\n vtsToCreateChildren.size() => ' + vtsToCreateChildren.size() + '\n');
		System.debug('\n vtsToCreateChildren => ' + JSON.serializePretty(vtsToCreateChildren) + '\n');
		if (vtsToCreateChildren.isEmpty() && vtRt != 'EUR_FI_Volume_Tracker') { return; }

		List<EUR_CRM_Volume_Tracker_Period__c> vtpsToInsert = this.makeVTPs(vts);
		System.debug('\n vtpsToInsert.size() => ' + vtpsToInsert.size() + '\n');
		System.debug('\n vtpsToInsert => ' + JSON.serializePretty(vtpsToInsert) + '\n');
		if (vtpsToInsert.isEmpty()) { return; }

		this.insertRecords(vtpsToInsert);

		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpisToInsert = this.makeVTPIs(vts);
		System.debug('\n vtpisToInsert.size() => ' + vtpisToInsert.size() + '\n');
		System.debug('\n vtpisToInsert => ' + JSON.serializePretty(vtpisToInsert) + '\n');
		if (vtpisToInsert.isEmpty()) { return; }

		this.insertRecords(vtpisToInsert);

	}


	/* ========================================================= */
	/*      Middle Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_GB_Volume_Tracker__c> getVTsToCreateChildrenForGB(List<EUR_CRM_GB_Volume_Tracker__c> vts) {
		List<EUR_CRM_GB_Volume_Tracker__c> vtsToCreateChildren = new List<EUR_CRM_GB_Volume_Tracker__c>();
		for (EUR_CRM_GB_Volume_Tracker__c vt : vts) {
			if ( ! this.isNeedToCreateChildrenForGB(vt)) { continue; }
			vtsToCreateChildren.add(vt);
		}
		return vtsToCreateChildren;
	}

	public Id getRtId(Map<String, String> childByParentRtDevName, Map<String, RecordTypeInfo> rtInfoByDevName, String
	parentRtDevName) {
		String childRtDevName = childByParentRtDevName.get(parentRtDevName);
		if (childRtDevName != null && rtInfoByDevName.containsKey(childRtDevName)) {
			return rtInfoByDevName.get(childRtDevName).getRecordTypeId();
		}
		return null;
	}


	/* ========================================================= */
	/*      Low Level Helpers
	/* ========================================================= */
	private Boolean isNeedToCreateChildrenForGB(EUR_CRM_GB_Volume_Tracker__c vt) {
		return ! vt.Volume_Tracker_Line_Items__r.isEmpty() && vt.Volume_Tracker_Period_EU__r.isEmpty();
	}

	/* ========================================================= */
	/*      Makers
	/* ========================================================= */
	private List<EUR_CRM_Volume_Tracker_Period__c> makeVTPs(List<EUR_CRM_GB_Volume_Tracker__c> vts) {
		List<EUR_CRM_Volume_Tracker_Period__c> vtpsToInsert = new List<EUR_CRM_Volume_Tracker_Period__c>();
		for (EUR_CRM_GB_Volume_Tracker__c vt : vts) {
			Id vtpRtId = this.getRtId(VTP_RT_BY_VT_RT, VTP_RT_INFO_BY_DEVNAME, vt.RecordType.DeveloperName);
			if (vtpRtId == null) { continue; }
			vtpsToInsert.add(this.makeVTP(vtpRtId, vt));
		}
		return vtpsToInsert;
	}

	private EUR_CRM_Volume_Tracker_Period__c makeVTP(Id rtId, EUR_CRM_GB_Volume_Tracker__c vt) {
		EUR_CRM_Volume_Tracker_Period__c vtp = new EUR_CRM_Volume_Tracker_Period__c(
			RecordTypeId = rtId
		,	EUR_CRM_Start_Date__c = vt.EUR_CRM_Contract__r.EUR_CRM_Start_Date__c
		,	EUR_CRM_Volume_Tracker_EU__c = vt.Id
		);

		this.setVtpEndDate(vtp, vt);
		return vtp;
	}

	private void setVtpEndDate(EUR_CRM_Volume_Tracker_Period__c vtp, EUR_CRM_GB_Volume_Tracker__c vt) {
		if (vt.EUR_CRM_Contract__r.EUR_CRM_Status__c != ACTIVATED) {
			vtp.EUR_CRM_End_Date__c = vt.EUR_CRM_Contract__r.EUR_CRM_End_Date__c;
		} else {
			vtp.EUR_CRM_End_Date__c = CURRENT_DATE;
		}
	}

	private List<EUR_CRM_Volume_Tracker_Period_Item__c> makeVTPIs(List<EUR_CRM_GB_Volume_Tracker__c> vts) {
		List<EUR_CRM_GB_Volume_Tracker__c> vtsToCreateVtpis = this.selectVTsWhereIds(vts);
		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpisToInsert = new List<EUR_CRM_Volume_Tracker_Period_Item__c>();
		for (EUR_CRM_GB_Volume_Tracker__c vt : vtsToCreateVtpis) {
			for (EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli : vt.Volume_Tracker_Line_Items__r) {
				Id vtpiRtId = this.getRtId(VTPI_RT_BY_VT_RT, VTPI_RT_INFO_BY_DEVNAME, vt.RecordType.DeveloperName);
				if (vtpiRtId == null) { continue; }
				vtpisToInsert.add(this.makeVTPI(vtpiRtId, vt.Volume_Tracker_Period_EU__r[0], vtli));
			}
		}
		return vtpisToInsert;
	}

	private EUR_CRM_Volume_Tracker_Period_Item__c makeVTPI(Id rtId, EUR_CRM_Volume_Tracker_Period__c vtp, EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli) {
		EUR_CRM_Volume_Tracker_Period_Item__c vtpi = new EUR_CRM_Volume_Tracker_Period_Item__c();
		vtpi.RecordTypeId = rtId;
		vtpi.EUR_CRM_Product__c = vtli.Id;
		vtpi.EUR_CRM_Volume_Tracker_Period__c = vtp.Id;
		vtpi.EUR_CRM_External_ID__c = vtli.EUR_CRM_External_ID__c;
		this.setVtpiActualVolume(vtpi, vtp, vtli);
		return vtpi;
	}

	private void setVtpiActualVolume(EUR_CRM_Volume_Tracker_Period_Item__c vtpi, EUR_CRM_Volume_Tracker_Period__c vtp, EUR_CRM_GB_Volume_Tracker_Line_Item__c vtli) {
		if (vtp.RecordType.DeveloperName.equalsIgnoreCase('EUR_GB_Volume_Tracker_Period')) {
			vtpi.EUR_CRM_Actual_Volume__c = vtli.EUR_CRM_Confirmed_Contract_to_Date_Volu__c;
		}
		else if (vtp.RecordType.DeveloperName.equalsIgnoreCase('EUR_FI_Volume_Tracker_Period')) {
			vtpi.EUR_CRM_Actual_Volume__c = vtp.EUR_CRM_Volume_by_Bottles__c;
		}
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_GB_Volume_Tracker__c> selectVTsWhereIds(List<EUR_CRM_GB_Volume_Tracker__c> vts) {
		return [
			SELECT Id
				,	RecordType.DeveloperName
				,	EUR_CRM_Contract__r.EUR_CRM_End_Date__c
				,	EUR_CRM_Contract__r.EUR_CRM_Start_Date__c
				,	EUR_CRM_Contract__r.EUR_CRM_Status__c
				,	(
				SELECT Id
					,	RecordType.DeveloperName
					,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_Start_Date__c
					,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_End_Date__c
					,	EUR_CRM_Volume_Tracker__r.EUR_CRM_Contract__r.EUR_CRM_Status__c
					,	EUR_CRM_Confirmed_Contract_to_Date_Volu__c
					,	EUR_CRM_External_ID__c
				FROM Volume_Tracker_Line_Items__r
			),	(
				SELECT Id
				,	RecordType.DeveloperName
				,	EUR_CRM_Volume_by_Bottles__c
				FROM Volume_Tracker_Period_EU__r
			)
			FROM EUR_CRM_GB_Volume_Tracker__c
			WHERE Id IN :vts
		];
	}



}