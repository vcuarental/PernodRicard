/*

	VTPI, vtpi, vtpis - EUR_CRM_Volume_Tracker_Period_Item__c
	VTP, vtp, vtps - EUR_CRM_Volume_Tracker_Period__c

	EUR_CRM_VolumeTrackerPeriodBatch creates records of EUR_CRM_Volume_Tracker_Period_Item__c for each EUR_CRM_Volume_Tracker_Period__c

						     =====
						    |  C  |
						     =====
						 	   |
						 	  |||
						 	 ======
						    |  VT  |
						     ======
                                |
			   |------------------------------------|
			  |||                                  |||
			======                                =====
		   | VTLI | ---------------------------<=| VTP |
			======                                =====
			  |                                     |
			  |                                     |
			  |			     ======                 |
			  |-----------<=| VTPI |=>--------------|
							 ======





* */
public with sharing class EUR_CRM_VolumeTrackerPeriodBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Database.Stateful{

//	private static final Map<String, String> VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE = new Map<String, String>{
//		'FI' => 'EUR_FI_VTPI_Record_Type'
//	};

	private static final Map<String, String> VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE =
		EUR_CRM_RecordTypeHelper_v2.getSettingsMap('EUR_CRM_VolumeTrackerPeriodBatch', 'VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE');
	
	private static final String FI_COUNTRY_CODE = 'FI';
	private static final Map<String, RecordTypeInfo> rtInfoByDevName = Schema.SObjectType.EUR_CRM_Volume_Tracker_Period_Item__c.getRecordTypeInfosByDeveloperName();
	private String countryCode;

	public EUR_CRM_VolumeTrackerPeriodBatch(String countryCode) {
		this.countryCode = countryCode == null ? FI_COUNTRY_CODE : countryCode;
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator([
			SELECT Id
			,	EUR_CRM_Volume_Tracker_EU__r.EUR_CRM_Contract__r.EUR_CRM_Country_Code__c
			,	EUR_CRM_Volume_Tracker_Line_Item__c
			,	EUR_CRM_Volume_Tracker_Line_Item__r.EUR_CRM_External_ID__c
			,	EUR_CRM_Volume_by_Bottles__c
			FROM EUR_CRM_Volume_Tracker_Period__c
			WHERE Id NOT IN (
				SELECT EUR_CRM_Volume_Tracker_Period__c
				FROM EUR_CRM_Volume_Tracker_Period_Item__c
			)
			AND EUR_CRM_Volume_Tracker_EU__r.EUR_CRM_Contract__r.EUR_CRM_Country_Code__c =: this.countryCode
			AND EUR_CRM_Volume_Tracker_Line_Item__c != NULL
		]);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Volume_Tracker_Period__c> vtps) {
		System.debug('\n vtps.size() => ' + vtps.size() + '\n');
		System.debug('\n vtps => ' + JSON.serializePretty(vtps) + '\n');

		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpisToInsert = this.getVtpisToInsert(vtps);
		System.debug('\n vtpisToInsert.size() => ' + vtpisToInsert.size() + '\n');
		System.debug('\n vtpisToInsert => ' + JSON.serializePretty(vtpisToInsert) + '\n');

		if (vtpisToInsert.isEmpty()) { return; }
		this.upsertRecords(vtpisToInsert);

		this.finish(bc);
	}



	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_Volume_Tracker_Period_Item__c> getVtpisToInsert(List<EUR_CRM_Volume_Tracker_Period__c> vtps) {
		List<EUR_CRM_Volume_Tracker_Period_Item__c> vtpisToInsert = new List<EUR_CRM_Volume_Tracker_Period_Item__c>();
		for (EUR_CRM_Volume_Tracker_Period__c vtp : vtps) {
			String countryCode = vtp.EUR_CRM_Volume_Tracker_EU__r.EUR_CRM_Contract__r.EUR_CRM_Country_Code__c;
			if ( ! VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE.containsKey(countryCode)) { continue; }
			String vtpiRt = VOLUME_TRACKER_PERIOD_ITEM_RT_BY_COUNTRY_CODE.get(countryCode);
			if ( ! rtInfoByDevName.containsKey(vtpiRt)) { continue; }
			Id vtpiRtId = rtInfoByDevName.get(vtpiRt).getRecordTypeId();
			vtpisToInsert.add(this.makeVTPI(vtpiRtId, vtp.EUR_CRM_Volume_Tracker_Line_Item__c, vtp.EUR_CRM_Volume_Tracker_Line_Item__r.EUR_CRM_External_ID__c, vtp));
		}
		return vtpisToInsert;
	}


	/* ========================================================= */
	/*     Makers
	/* ========================================================= */
	private EUR_CRM_Volume_Tracker_Period_Item__c makeVTPI (Id rtId, Id vtliId, String extId, EUR_CRM_Volume_Tracker_Period__c vtp) {
		return new EUR_CRM_Volume_Tracker_Period_Item__c(
			RecordTypeId = rtId
		,	EUR_CRM_Volume_Tracker_Period__c = vtp.Id
		,	EUR_CRM_Product__c = vtliId
		,	EUR_CRM_External_ID__c = extId
		,	EUR_CRM_Actual_Volume__c = vtp.EUR_CRM_Volume_by_Bottles__c
		);
	}

}