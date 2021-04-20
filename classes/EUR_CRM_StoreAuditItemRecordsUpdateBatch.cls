global with sharing class EUR_CRM_StoreAuditItemRecordsUpdateBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	private static final Set<String> OLD_SAI_RT_NEED_TO_UPDATE = new Set<String>{
		'EUR_DE_Off_Trade_Store_Audit'
	,	'EUR_DE_On_Trade_Store_Audit'
	};

	private static final Datetime CREATED_DATE_TO_UPDATE_FROM = DateTime.newInstance(2019, 3, 1, 0, 0, 0);

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT Id
			,	EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName
			,	RecordType.DeveloperName
			FROM EUR_CRM_Store_Audit_Item__c
			WHERE RecordType.DeveloperName IN :OLD_SAI_RT_NEED_TO_UPDATE
			AND CreatedDate >= :CREATED_DATE_TO_UPDATE_FROM
		]);
	}

	global void execute(Database.BatchableContext BC, List<EUR_CRM_Store_Audit_Item__c> sais) {
		List<EUR_CRM_Store_Audit_Item__c> saisToUpdate = this.updateSAIrecordType(sais);
		this.upsertRecords(saisToUpdate);
	}

	global override void finish(Database.BatchableContext BC) {
		this.sendEmailReport(BC);
	}


	/* ========================================================= */
	/*      High Level Helpers
	/* ========================================================= */
	private List<EUR_CRM_Store_Audit_Item__c> updateSAIrecordType(List<EUR_CRM_Store_Audit_Item__c> sais) {
		List<EUR_CRM_Store_Audit_Item__c> saisToUpdate = new List<EUR_CRM_Store_Audit_Item__c>();
		Map<String, RecordTypeInfo> rtInfoByDevName = Schema.SObjectType.EUR_CRM_Store_Audit_Item__c.getRecordTypeInfosByDeveloperName();
		Map<String, String> saiRTbyAccRT = this.getSAIrtByAccRTWhereCountryCode('DE');
		for (EUR_CRM_Store_Audit_Item__c sai : sais) {
			if (saiRTbyAccRT.containsKey(sai.EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName)) {
				String newSAIrtDevName = saiRTbyAccRT.get(sai.EUR_CRM_Store_Audit__r.EUR_CRM_Account__r.RecordType.DeveloperName);
				if ( ! rtInfoByDevName.containsKey(newSAIrtDevName)) { continue; }
				sai.RecordTypeId = rtInfoByDevName.get(newSAIrtDevName).getRecordTypeId();
				saisToUpdate.add(sai);
			}
		}
		return saisToUpdate;
	}

	private Map<String, String> getSAIrtByAccRTWhereCountryCode(String countryCode) {
		Map<String, String> saiRTbyAccRT = new Map<String, String>();
		List<EUR_CRM_CTM_ActivityAuditSettings__mdt> activityAuditSettings = selectActivityAuditSettingsWhereCountryCode(countryCode);
		for (EUR_CRM_CTM_ActivityAuditSettings__mdt aas : activityAuditSettings) {
			saiRTbyAccRT.put(aas.EUR_CRM_Account_Record_Type__c, aas.StoreAuditItemRecordType__c);
		}
		return saiRTbyAccRT;
	}


	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private List<EUR_CRM_CTM_ActivityAuditSettings__mdt> selectActivityAuditSettingsWhereCountryCode(String countryCode) {
		return [
			SELECT Id
			,	EUR_CRM_Account_Record_Type__c
			,	StoreAuditItemRecordType__c
			FROM EUR_CRM_CTM_ActivityAuditSettings__mdt
			WHERE Country__c =: countryCode
		];
	}
}