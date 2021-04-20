public with sharing class EUR_CRM_StoreAuditItemConkerUpdate extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

	private Set<String> rtDevNames;
	private Datetime startDatetime;
	private Datetime endDatetime;
//	private Integer batchSize = 200;


	//Batch Interfaces
	public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames) {
		Database.executeBatch(new EUR_CRM_StoreAuditItemConkerUpdate(rtDevNames));
	}

	public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_StoreAuditItemConkerUpdate(rtDevNames), batchSize);
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		Database.executeBatch(new EUR_CRM_StoreAuditItemConkerUpdate(rtDevNames, startDatetime, endDatetime));
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_StoreAuditItemConkerUpdate(rtDevNames, startDatetime, endDatetime), batchSize);
	}

	//Constructors
	public EUR_CRM_StoreAuditItemConkerUpdate() {}

	public EUR_CRM_StoreAuditItemConkerUpdate(Set<String> rtDevNames) {
		this.rtDevNames = rtDevNames;
	}

	public EUR_CRM_StoreAuditItemConkerUpdate(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime) {
		this.rtDevNames = rtDevName;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
	}

//	public EUR_CRM_StoreAuditItemConkerUpdate(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
//		this.rtDevNames = rtDevName;
//		this.startDatetime = startDatetime;
//		this.endDatetime = endDatetime;
//		this.batchSize = batchSize;
//	}


	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			this.buildSaisQuery(this.rtDevNames, this.startDatetime, this.endDatetime)
		);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Store_Audit_Item__c> sais) {
		Map<Id, List<EUR_CRM_Store_Audit_Item__c>> saisBySaId = this.getSaisBySaId(sais);

		List<EUR_CRM_Store_Audit_Item__c> saisToUpdate = new List<EUR_CRM_Store_Audit_Item__c>();
		for (Id saId : saisBySaId.keySet()) {
			List<EUR_CRM_Store_Audit_Item__c> saisToProceed = saisBySaId.get(saId);
			Integer notListedCount = 0;
			Integer allSaiCount = 0;
			for (EUR_CRM_Store_Audit_Item__c sai : saisToProceed) {
				String sumStr = sai.EUR_CRM_Store_Audit__r.EUR_CRM_Audit_Summary__c.split(' ')[0];
				if ( ! sumStr.isNumeric()) { break; }
				allSaiCount = Integer.valueOf(sumStr);
				if (sai.EUR_JB_Listed__c) { continue; }
				notListedCount++;
			}
			if (notListedCount == allSaiCount && allSaiCount == saisToProceed.size()) {
				saisToUpdate.addAll(saisToProceed);
			}
		}

		this.updateSais(saisToUpdate);
		System.debug('\n saisToUpdate.size() => ' + saisToUpdate.size() + '\n');
		System.debug('\n saisToUpdate => ' + JSON.serializePretty(saisToUpdate) + '\n');
		this.upsertRecords(saisToUpdate);
	}

	//High level helpers
	@TestVisible
	private String buildSaisQuery(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		String query = 'SELECT EUR_CRM_Store_Audit__c ' +
			' , EUR_JB_Listed__c ' +
			' , EUR_CRM_Store_Audit__r.EUR_CRM_Audit_Summary__c ' +
			' , EUR_CRM_Store_Audit__r.EUR_CRM_Is_Latest_Store_Audit_Formula__c ' +
			' FROM EUR_CRM_Store_Audit_Item__c ' +
			' WHERE EUR_CRM_Store_Audit__c IN ( ' +
			' SELECT Id FROM EUR_CRM_Store_Audit__c ' +
				' WHERE RecordType.DeveloperName IN :rtDevNames ' +
				' AND EUR_CRM_Is_Latest_Store_Audit_Formula__c = TRUE ' +
				' AND EUR_CRM_Audit_Summary__c != NULL ' +
				(startDatetime == null ? '' : ' AND CreatedDate >= :startDatetime ') +
				(endDatetime == null ? '' : ' AND CreatedDate < :endDatetime ') +
			' ) '
		;
		System.debug('\n sas query => ' + query + '\n');
		return query;
	}

	private Map<Id, List<EUR_CRM_Store_Audit_Item__c>> getSaisBySaId(List<EUR_CRM_Store_Audit_Item__c> sais) {
		Map<Id, List<EUR_CRM_Store_Audit_Item__c>> saisBySaId = new Map<Id, List<EUR_CRM_Store_Audit_Item__c>>();
		for (EUR_CRM_Store_Audit_Item__c sai : sais) {
			if(saisBySaId.containsKey(sai.EUR_CRM_Store_Audit__c)) {
				saisBySaId.get(sai.EUR_CRM_Store_Audit__c).add(sai);
			} else {
				saisBySaId.put(sai.EUR_CRM_Store_Audit__c, new List<EUR_CRM_Store_Audit_Item__c>{ sai });
			}
		}
		return saisBySaId;
	}

	private void updateSais(List<EUR_CRM_Store_Audit_Item__c> sais) {
		for (EUR_CRM_Store_Audit_Item__c sai : sais) {
			sai.EUR_JB_Listed__c = true;
		}
	}

}