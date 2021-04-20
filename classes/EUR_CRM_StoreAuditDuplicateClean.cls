public with sharing class EUR_CRM_StoreAuditDuplicateClean extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable{

	@TestVisible
	private static final String EUR_CRM_STORE_AUDIT_DUPLICATE_CLEAN = 'EUR_CRM_StoreAuditDuplicateClean';

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
			EUR_CRM_STORE_AUDIT_DUPLICATE_CLEAN + ' at ' + cronExpression,
			cronExpression,
			new EUR_CRM_StoreAuditDuplicateClean(rtDevNames, startDatetime, endDatetime, batchSize)
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
		Database.executeBatch(new EUR_CRM_StoreAuditDuplicateClean(rtDevNames));
	}

	public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_StoreAuditDuplicateClean(rtDevNames), batchSize);
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		Database.executeBatch(new EUR_CRM_StoreAuditDuplicateClean(rtDevNames, startDatetime, endDatetime));
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_StoreAuditDuplicateClean(rtDevNames, startDatetime, endDatetime), batchSize);
	}



	//Constructors
	public EUR_CRM_StoreAuditDuplicateClean() {}

	public EUR_CRM_StoreAuditDuplicateClean(Set<String> rtDevNames) {
		this.rtDevNames = rtDevNames;
	}

	public EUR_CRM_StoreAuditDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime) {
		this.rtDevNames = rtDevName;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
	}

	public EUR_CRM_StoreAuditDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
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
			this.buildSaisQuery(this.rtDevNames, this.startDatetime, this.endDatetime)
		);
	}

	public void execute(Database.BatchableContext bc, List<SObject> sobjects) {
		new Service().deleteSasDuplicates((List<EUR_CRM_Visit__c>) sobjects);
	}



	//Inner Service class
	public class Service {

		@TestVisible private List<EUR_CRM_Store_Audit__c> sasToDelete = new List<EUR_CRM_Store_Audit__c>();

		public void deleteSasDuplicates(List<EUR_CRM_Visit__c> visits) {
			Map<Id, EUR_CRM_Store_Audit__c> sasWithRelativesById = this.getSasWithRelativesById(visits);

			Map<Id, Map<String, List<EUR_CRM_Store_Audit__c>>> sasByMobileIdByVisitId = this.getSasByMobileIdByVisitId(visits, sasWithRelativesById);

//			List<EUR_CRM_Store_Audit__c> sasToDelete = this.getSasToDelete(sasByMobileIdByVisitId);
			List<EUR_CRM_Store_Audit__c> sasToDelete = this.getSasToDelete(sasByMobileIdByVisitId, sasWithRelativesById);
			this.sasToDelete.addAll(sasToDelete);

			Database.delete(this.sasToDelete, false);
		}


		//High level helpers
		private Map<Id, Map<String, List<EUR_CRM_Store_Audit__c>>> getSasByMobileIdByVisitId(List<EUR_CRM_Visit__c> visits, Map<Id, EUR_CRM_Store_Audit__c> sasWithRelativesById) {
			Map<Id, Map<String, List<EUR_CRM_Store_Audit__c>>> sasByMobileIdByVisitId = new Map<Id, Map<String, List<EUR_CRM_Store_Audit__c>>>();
			for (EUR_CRM_Visit__c visit : visits) {
				for (EUR_CRM_Store_Audit__c sa : visit.Store_Audits__r) {
//					EUR_CRM_Store_Audit__c saWithRelatives = sasWithRelativesById.get(sa.Id);
					if (sa.EUR_CRM_Mobile_ID__c != null) {

						//populate sasByMobileIdByVisitId
						if (sasByMobileIdByVisitId.containsKey(sa.EUR_CRM_Visit__c)) {
							if (sasByMobileIdByVisitId.get(sa.EUR_CRM_Visit__c).containsKey(sa.EUR_CRM_Mobile_ID__c)) {
								sasByMobileIdByVisitId.get(sa.EUR_CRM_Visit__c).get(sa.EUR_CRM_Mobile_ID__c).add(sa);
							} else {
								sasByMobileIdByVisitId.get(sa.EUR_CRM_Visit__c).put(sa.EUR_CRM_Mobile_ID__c, new List<EUR_CRM_Store_Audit__c>{ sa });
							}
						} else {
							sasByMobileIdByVisitId.put(sa.EUR_CRM_Visit__c,
								new Map<String, List<EUR_CRM_Store_Audit__c>>{
									sa.EUR_CRM_Mobile_ID__c =>  new List<EUR_CRM_Store_Audit__c>{ sa }}
							);
						}

					}
				}
			}
			return sasByMobileIdByVisitId;
		}

		private Map<Id, EUR_CRM_Store_Audit__c> getSasWithRelativesById(List<EUR_CRM_Visit__c> visits) {
			List<EUR_CRM_Store_Audit__c> sasToSelect = this.getSasToSelect(visits);
			return new Map<Id, EUR_CRM_Store_Audit__c>(this.selectStoreAuditsWhereIds(sasToSelect));
		}

		private List<EUR_CRM_Store_Audit__c> getSasToSelect(List<EUR_CRM_Visit__c> visits) {
			List<EUR_CRM_Store_Audit__c> sasToSelect = new List<EUR_CRM_Store_Audit__c>();
			for (EUR_CRM_Visit__c visit : visits) {
				sasToSelect.addAll(visit.Store_Audits__r);
			}
			return sasToSelect;
		}


		//Middle level helpers
//		private List<EUR_CRM_Store_Audit__c> getSasToDelete(Map<Id, Map<String, List<EUR_CRM_Store_Audit__c>>> sasByMobileIdByVisitId) {
//			List<EUR_CRM_Store_Audit__c> sasToDelete = new List<EUR_CRM_Store_Audit__c>();
//			for (Id visitId : sasByMobileIdByVisitId.keySet()) {
//				Map<String, List<EUR_CRM_Store_Audit__c>> sasByMobileId = sasByMobileIdByVisitId.get(visitId);
//				for (String mobileId : sasByMobileId.keySet()) {
//					List<EUR_CRM_Store_Audit__c> sas = sasByMobileId.get(mobileId);
//					if (sas.size() > 1) {
//						sasToDelete.addAll(this.addAllExceptOneElementToList(sas));
//					}
//				}
//			}
//			return sasToDelete;
//		}

		private List<EUR_CRM_Store_Audit__c> getSasToDelete(Map<Id, Map<String, List<EUR_CRM_Store_Audit__c>>> sasByMobileIdByVisitId, Map<Id, EUR_CRM_Store_Audit__c> sasWithRelativesById) {
			List<EUR_CRM_Store_Audit__c> sasToDelete = new List<EUR_CRM_Store_Audit__c>();
			for (Id visitId : sasByMobileIdByVisitId.keySet()) {
				Map<String, List<EUR_CRM_Store_Audit__c>> sasByMobileId = sasByMobileIdByVisitId.get(visitId);
				for (String mobileId : sasByMobileId.keySet()) {
					List<EUR_CRM_Store_Audit__c> sas = sasByMobileId.get(mobileId);
					if (sas.size() > 1) {
						sasToDelete.addAll(this.getSasWithoutChildrenToDelete(sas, sasWithRelativesById));
					}
				}
			}
			return sasToDelete;
		}

		private List<EUR_CRM_Store_Audit__c> getSasWithoutChildrenToDelete(List<EUR_CRM_Store_Audit__c> sas, Map<Id, EUR_CRM_Store_Audit__c> sasWithRelativesById) {
			List<EUR_CRM_Store_Audit__c> sasToDelete = new List<EUR_CRM_Store_Audit__c>();

			Integer paWithChildrenCount = 0;
			for (EUR_CRM_Store_Audit__c sa : sas) {
				EUR_CRM_Store_Audit__c saWithRelatives = sasWithRelativesById.get(sa.Id);
				if ( ! saWithRelatives.Store_Audit_Items__r.isEmpty()) {
					paWithChildrenCount++;
				} else {
					sasToDelete.add(sa);
				}
			}
			return paWithChildrenCount == 0 ? this.addAllExceptOneElementToList(sasToDelete) : sasToDelete;
		}

		private List<EUR_CRM_Store_Audit__c> addAllExceptOneElementToList(List<EUR_CRM_Store_Audit__c> sas) {
			sas.remove(0);
			return sas;
		}

		//Low level helpers
//		private List<EUR_CRM_Store_Audit__c> addAllExceptOneElementToList(List<EUR_CRM_Store_Audit__c> sas) {
//			List<EUR_CRM_Store_Audit__c> sasToDelete = new List<EUR_CRM_Store_Audit__c>();
//			for (Integer i = 0; i < sas.size() - 1; i++) {
//				sasToDelete.add(sas.get(i));
//			}
//			return sasToDelete;
//		}

		//Selectors
		private List<EUR_CRM_Store_Audit__c> selectStoreAuditsWhereIds(List<EUR_CRM_Store_Audit__c> sas) {
			return [
				SELECT Id
					,   EUR_CRM_Visit__c
					,   EUR_CRM_Mobile_ID__c
					,   (
					SELECT Id
					FROM Store_Audit_Items__r
				)
				FROM EUR_CRM_Store_Audit__c
				WHERE Id IN :sas
			];
		}


	}


	//High level helpers
	@TestVisible
	private String buildSaisQuery(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		String query = 'SELECT Id, ' +
		' ( ' +
		' SELECT Id, EUR_CRM_Mobile_ID__c, EUR_CRM_Visit__c ' +
		' FROM Store_Audits__r) ' +
		' FROM EUR_CRM_Visit__c ' +
		' WHERE Id IN ( ' +
			' SELECT EUR_CRM_Visit__c ' +
			' FROM EUR_CRM_Store_Audit__c ' +
			' WHERE EUR_CRM_Mobile_ID__c != NULL ' +
			' AND RecordType.DeveloperName IN :rtDevNames ' +
			(startDatetime == null ? '' : ' AND CreatedDate >= :startDatetime ') +
			(endDatetime == null ? '' : ' AND CreatedDate < :endDatetime ') +
		' )';
		System.debug('\n sas query => ' + query + '\n');
		return query;
	}


	//Selectors
	private static List<CronTrigger> selectCronTriggers() {
		return [
			SELECT Id
				,   CronJobDetail.Name
				,   CronExpression
				,   NextFireTime
			FROM CronTrigger
			WHERE CronJobDetail.Name LIKE :EUR_CRM_STORE_AUDIT_DUPLICATE_CLEAN + '%'
		];
	}

}