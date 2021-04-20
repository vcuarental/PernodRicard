public with sharing class EUR_CRM_PriceAuditItemsDuplicateClean extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable{

	@TestVisible
	private static final String EUR_CRM_PRICE_AUDIT_ITEMS_DUPLICATE_CLEAN = 'EUR_CRM_PriceAuditItemsDuplicateClean';

	private Set<String> rtDevNames;
	private Datetime startDatetime;
	private Datetime endDatetime;
	private Integer batchSize = 200;


	//Schedule interfaces
	/*
	* Cron expression example:
	* Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
	* String cronExpr = '0 0 1 * * ?'; Class runs every day at 1 AM.
	*/
	public static String scheduleCleanRecordsWhereRtDevNameAndDates(String cronExpression, Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
		return System.schedule(
			EUR_CRM_PRICE_AUDIT_ITEMS_DUPLICATE_CLEAN + ' at ' + cronExpression,
			cronExpression,
			new EUR_CRM_PriceAuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime, batchSize)
		);
	}

	public static void removeSchedules() {
		List<CronTrigger> cronTriggers = selectCronTriggers();
		for(CronTrigger ct : cronTriggers) {
			System.abortJob(ct.Id);
		}
	}


	//Batch Interfaces
	public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames) {
		Database.executeBatch(new EUR_CRM_PriceAuditItemsDuplicateClean(rtDevNames));
	}

	public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_PriceAuditItemsDuplicateClean(rtDevNames), batchSize);
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		Database.executeBatch(new EUR_CRM_PriceAuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime));
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_PriceAuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime), batchSize);
	}



	//Constructors
	public EUR_CRM_PriceAuditItemsDuplicateClean() {}

	public EUR_CRM_PriceAuditItemsDuplicateClean(Set<String> rtDevNames) {
		this.rtDevNames = rtDevNames;
	}

	public EUR_CRM_PriceAuditItemsDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime) {
		this.rtDevNames = rtDevName;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
	}

	public EUR_CRM_PriceAuditItemsDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
		this.rtDevNames = rtDevName;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
		this.batchSize = batchSize;
	}

	//Schedulable
	public void execute(SchedulableContext sc) {
		Database.executeBatch(
			this, this.batchSize
		);
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			this.buildPaisQuery(this.rtDevNames, this.startDatetime, this.endDatetime)
		);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Price_Audit_Item__c> pais) {
		deletePaisDuplicates(pais);
	}


	//High level helpers
	public void deletePaisDuplicates(List<EUR_CRM_Price_Audit_Item__c> pais) {
		Map<String, List<EUR_CRM_Price_Audit_Item__c>> paisByCustKey = this.getPaisByCustKey(pais);

		List<EUR_CRM_Price_Audit_Item__c> paisToDelete = this.getPaisToDelete(paisByCustKey);
		Database.delete(paisToDelete, false);
	}

	private Map<String, List<EUR_CRM_Price_Audit_Item__c>> getPaisByCustKey(List<EUR_CRM_Price_Audit_Item__c> pais) {
		Map<String, List<EUR_CRM_Price_Audit_Item__c>> paisByCustKey = new Map<String, List<EUR_CRM_Price_Audit_Item__c>>();
		for (EUR_CRM_Price_Audit_Item__c pai : pais) {

			String custKey = '' + pai.EUR_CRM_Price_Audit__c + pai.EUR_CRM_Brand_Quality_Size__c;
			if ( ! paisByCustKey.containsKey(custKey)) {
				paisByCustKey.put(custKey, new List<EUR_CRM_Price_Audit_Item__c>());
			}
			paisByCustKey.get(custKey).add(pai);
		}
		return paisByCustKey;
	}

	private List<EUR_CRM_Price_Audit_Item__c> getPaisToDelete(Map<String, List<EUR_CRM_Price_Audit_Item__c>> paisByCustKey) {
		List<EUR_CRM_Price_Audit_Item__c> paisToDelete = new List<EUR_CRM_Price_Audit_Item__c>();
		for (String custKey : paisByCustKey.keySet()) {
			List<EUR_CRM_Price_Audit_Item__c> pais = paisByCustKey.get(custKey);
			if (pais.size() <= 1) { continue; }
			EUR_CRM_Price_Audit_Item__c removedPAI;
			for (Integer i = pais.size() -1 ; i > 0; i --) {
				if (pais[i].EUR_CRM_Retail_Sales_Price__c != null) {
					removedPAI = (EUR_CRM_Price_Audit_Item__c) pais.remove(i); }
					break;
			}
			if (removedPAI == null) { pais.remove(0); }
			paisToDelete.addAll(pais);
		}
		return paisToDelete;
	}

	@TestVisible
	private String buildPaisQuery(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		if (rtDevNames == null) {
			rtDevNames = getAllPaisRtDevNames();
		}
		String query = 'SELECT Id, EUR_CRM_Price_Audit__c, EUR_CRM_Mobile_ID__c,  EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Retail_Sales_Price__c ' +
			' FROM EUR_CRM_Price_Audit_Item__c ' +
			' WHERE RecordType.DeveloperName IN :rtDevNames ' +
			(startDatetime == null ? '' : ' AND EUR_CRM_Price_Audit__r.CreatedDate >= :startDatetime ') +
			(endDatetime == null ? '' : ' AND EUR_CRM_Price_Audit__r.CreatedDate <= :endDatetime ') +
			' ORDER BY EUR_CRM_Price_Audit__c, EUR_CRM_Brand_Quality_Size__c';
		System.debug('\n pais query => ' + query + '\n');
		return query;
	}

	private Set<String> getAllPaisRtDevNames() {
		return SObjectType.EUR_CRM_Price_Audit_Item__c.getRecordTypeInfosByDeveloperName().keySet();
	}

	private  static List<CronTrigger> selectCronTriggers() {
		return [
			SELECT Id
				,   CronJobDetail.Name
				,   CronExpression
				,   NextFireTime
			FROM CronTrigger
			WHERE CronJobDetail.Name LIKE :EUR_CRM_PRICE_AUDIT_ITEMS_DUPLICATE_CLEAN + '%'
		];
	}
}