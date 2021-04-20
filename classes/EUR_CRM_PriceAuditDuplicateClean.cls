public with sharing class EUR_CRM_PriceAuditDuplicateClean extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable{

	@TestVisible
	private static final String EUR_CRM_PRICE_AUDIT_DUPLICATE_CLEAN = 'EUR_CRM_PriceAuditDuplicateClean';

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
			EUR_CRM_PRICE_AUDIT_DUPLICATE_CLEAN + ' at ' + cronExpression,
			cronExpression,
			new EUR_CRM_PriceAuditDuplicateClean(rtDevNames, startDatetime, endDatetime, batchSize)
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
		Database.executeBatch(new EUR_CRM_PriceAuditDuplicateClean(rtDevNames));
	}

	public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_PriceAuditDuplicateClean(rtDevNames), batchSize);
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		Database.executeBatch(new EUR_CRM_PriceAuditDuplicateClean(rtDevNames, startDatetime, endDatetime));
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_PriceAuditDuplicateClean(rtDevNames, startDatetime, endDatetime), batchSize);
	}



	//Constructors
	public EUR_CRM_PriceAuditDuplicateClean() {}

	public EUR_CRM_PriceAuditDuplicateClean(Set<String> rtDevNames) {
		this.rtDevNames = rtDevNames;
	}

	public EUR_CRM_PriceAuditDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime) {
		this.rtDevNames = rtDevName;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
	}

	public EUR_CRM_PriceAuditDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
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
			this.buildPasQuery(this.rtDevNames, this.startDatetime, this.endDatetime)
		);
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Price_Audit__c> pas) {
		this.deletePasDuplicates(pas);
	}

	//High level helpers
	@TestVisible
	private String buildPasQuery(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		String query = 'SELECT Id, ' +
			' EUR_CRM_Visit__c, ' +
			' EUR_CRM_Mobile_ID__c ' +
			' FROM EUR_CRM_Price_Audit__c ' +
			' WHERE EUR_CRM_Mobile_ID__c != NULL ' +
			' AND RecordType.DeveloperName IN :rtDevNames ' +
			(startDatetime == null ? '' : ' AND CreatedDate >= :startDatetime ') +
			(endDatetime == null ? '' : ' AND CreatedDate < :endDatetime ')
			;
		System.debug('\n pas query => ' + query + '\n');
		return query;
	}

	public void deletePasDuplicates(List<EUR_CRM_Price_Audit__c> pas) {
		Map<Id, Integer> paisCountByPaId = this.getPaisCountByPaId(pas);
//		System.debug('\n paisCountByPaId.size() => ' + paisCountByPaId.size() + '\n');
//		System.debug('\n paisCountByPaId => ' + JSON.serializePretty(paisCountByPaId) + '\n');
		Map<Id, Map<String, List<EUR_CRM_Price_Audit__c>>> pasByMobileIdByVisitId = this.getPasByMobileIdByVisitId(pas);
//		System.debug('\n pasByMobileIdByVisitId.size() => ' + pasByMobileIdByVisitId.size() + '\n');
//		System.debug('\n pasByMobileIdByVisitId => ' + JSON.serializePretty(pasByMobileIdByVisitId) + '\n');

		List<EUR_CRM_Price_Audit__c> pasToDelete = this.getPasToDelete(pasByMobileIdByVisitId, paisCountByPaId);
		System.debug('\n pasToDelete.size() => ' + pasToDelete.size() + '\n');
//		System.debug('\n pasToDelete => ' + JSON.serializePretty(pasToDelete) + '\n');
		this.deleteRecords(pasToDelete);
	}

	//Middle level helpers
	private Map<Id, Integer> getPaisCountByPaId(List<EUR_CRM_Price_Audit__c> pas) {
		Map<Id, Integer> paisCountByPaId = new Map<Id, Integer>();
		Set<Id> paIds = new Map<Id, EUR_CRM_Price_Audit__c>(pas).keySet();
		List<AggregateResult> agrsResults = this.selectPaisAggregateResults(paIds);
		for (AggregateResult ar : agrsResults) {
			Integer paisCount = (Integer) ar.get('Pais');
			Id paId = (Id) ar.get('EUR_CRM_Price_Audit__c');

			paisCountByPaId.put(paId, paisCount);
		}
		return paisCountByPaId;
	}

	private Map<Id, Map<String, List<EUR_CRM_Price_Audit__c>>> getPasByMobileIdByVisitId(List<EUR_CRM_Price_Audit__c> pas) {
		Map<Id, Map<String, List<EUR_CRM_Price_Audit__c>>> pasByMobileIdByVisitId = new Map<Id, Map<String, List<EUR_CRM_Price_Audit__c>>>();
		for (EUR_CRM_Price_Audit__c pa : pas) {
			if (pa.EUR_CRM_Mobile_Id__c == null) { continue; }

			//populate pasByMobileIdByVisitId
			if (pasByMobileIdByVisitId.containsKey(pa.EUR_CRM_Visit__c)) {
				if (pasByMobileIdByVisitId.get(pa.EUR_CRM_Visit__c).containsKey(pa.EUR_CRM_Mobile_Id__c)) {
					pasByMobileIdByVisitId.get(pa.EUR_CRM_Visit__c).get(pa.EUR_CRM_Mobile_Id__c).add(pa);
				} else {
					pasByMobileIdByVisitId.get(pa.EUR_CRM_Visit__c).put(pa.EUR_CRM_Mobile_Id__c, new List<EUR_CRM_Price_Audit__c>{ pa });
				}
			} else {
				pasByMobileIdByVisitId.put(pa.EUR_CRM_Visit__c,
					new Map<String, List<EUR_CRM_Price_Audit__c>>{
						pa.EUR_CRM_Mobile_Id__c =>  new List<EUR_CRM_Price_Audit__c>{ pa }}
				);
			}

			}
		return pasByMobileIdByVisitId;
	}

	private List<EUR_CRM_Price_Audit__c> getPasToDelete(Map<Id, Map<String, List<EUR_CRM_Price_Audit__c>>> pasByMobileIdByVisitId, Map<Id, Integer> paisCountByPaId) {
		List<EUR_CRM_Price_Audit__c> pasToDelete = new List<EUR_CRM_Price_Audit__c>();
		for (Id visitId : pasByMobileIdByVisitId.keySet()) {
			Map<String, List<EUR_CRM_Price_Audit__c>> pasByMobileId = pasByMobileIdByVisitId.get(visitId);
			for (String mobileId : pasByMobileId.keySet()) {
				List<EUR_CRM_Price_Audit__c> pas = pasByMobileId.get(mobileId);
				if (pas.size() > 1) {
					//not delete PAs that have PAIs
					pasToDelete.addAll(this.getPasWithoutChildrenToDelete(pas, paisCountByPaId));
				}
			}
		}
		return pasToDelete;
	}

	//Low level helpers
	private List<EUR_CRM_Price_Audit__c> getPasWithoutChildrenToDelete(List<EUR_CRM_Price_Audit__c> pas, Map<Id, Integer> paisCountByPaId) {
		List<EUR_CRM_Price_Audit__c> pasToDelete = new List<EUR_CRM_Price_Audit__c>();

		Integer paWithChildrenCount = 0;
		for (EUR_CRM_Price_Audit__c pa : pas) {
			Integer paisCount = paisCountByPaId.get(pa.Id);
			if (paisCount != null && paisCount != 0) {
				paWithChildrenCount++;
			} else {
				pasToDelete.add(pa);
			}
		}
		return paWithChildrenCount == 0 ? this.addAllExceptOneElementToList(pasToDelete) : pasToDelete;
	}

	private List<EUR_CRM_Price_Audit__c> addAllExceptOneElementToList(List<EUR_CRM_Price_Audit__c> pas) {
		pas.remove(0);
		return pas;
	}



	//Selectors
	private static List<CronTrigger> selectCronTriggers() {
		return [
			SELECT Id
				,   CronJobDetail.Name
				,   CronExpression
				,   NextFireTime
			FROM CronTrigger
			WHERE CronJobDetail.Name LIKE :EUR_CRM_PRICE_AUDIT_DUPLICATE_CLEAN + '%'
		];
	}

	private List<AggregateResult> selectPaisAggregateResults(Set<Id> paIds) {
		return [
			SELECT EUR_CRM_Price_Audit__c, COUNT(Id) Pais
			FROM EUR_CRM_Price_Audit_Item__c
			WHERE EUR_CRM_Price_Audit__c IN :paIds
			GROUP BY EUR_CRM_Price_Audit__c
		];
	}

}