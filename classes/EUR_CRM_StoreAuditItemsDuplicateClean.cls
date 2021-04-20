public with sharing class EUR_CRM_StoreAuditItemsDuplicateClean extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable{

	@TestVisible
	private static final String EUR_CRM_STORE_AUDIT_ITEMS_DUPLICATE_CLEAN = 'EUR_CRM_StoreAuditItemsDuplicateClean';

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
			EUR_CRM_STORE_AUDIT_ITEMS_DUPLICATE_CLEAN + ' at ' + cronExpression,
			cronExpression,
			new EUR_CRM_StoreAuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime, batchSize)
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
		Database.executeBatch(new EUR_CRM_StoreAuditItemsDuplicateClean(rtDevNames));
	}

	public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_StoreAuditItemsDuplicateClean(rtDevNames), batchSize);
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		Database.executeBatch(new EUR_CRM_StoreAuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime));
	}

	public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_StoreAuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime), batchSize);
	}



	//Constructors
	public EUR_CRM_StoreAuditItemsDuplicateClean() {}

	public EUR_CRM_StoreAuditItemsDuplicateClean(Set<String> rtDevNames) {
		this.rtDevNames = rtDevNames;
	}

	public EUR_CRM_StoreAuditItemsDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime) {
		this.rtDevNames = rtDevName;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
	}

	public EUR_CRM_StoreAuditItemsDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
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
			this.buildSaisQueryRegardlessMobileId(this.rtDevNames, this.startDatetime, this.endDatetime)
		);
	}

	public void execute(Database.BatchableContext bc, List<SObject> sobjects) {

		RegardlessMobileIdService service = new RegardlessMobileIdService();
		List<EUR_CRM_Store_Audit_Item__c> saisToDelete = service.deleteSAIsDuplicates((List<EUR_CRM_Store_Audit_Item__c>) sobjects);

		System.debug('\n saisToDelete.size() => ' + saisToDelete.size() + '\n');
		this.deleteRecords(saisToDelete);
	}


	//Inner service class
	public class RegardlessMobileIdService {

		public List<EUR_CRM_Store_Audit_Item__c> deleteSAIsDuplicates(List<EUR_CRM_Store_Audit_Item__c> sais) {
			Map<Id, Map<String, List<EUR_CRM_Store_Audit_Item__c>>> saisByByCustKeyBySAid =
				this.getSAIsByCustKeyBySAid(sais);

			System.debug('\n saisByByCustKeyBySAid.size() => ' + saisByByCustKeyBySAid.size() + '\n');

			List<EUR_CRM_Store_Audit_Item__c> saisToDelete = this.getSaisToDelete(saisByByCustKeyBySAid);
			System.debug('\n saisToDelete.size() => ' + saisToDelete.size() + '\n');
			return saisToDelete;
		}

		public Map<Id, Map<String, List<EUR_CRM_Store_Audit_Item__c>>> getSAIsByCustKeyBySAid(List<EUR_CRM_Store_Audit_Item__c> sais) {
			Map<Id, Map<String, List<EUR_CRM_Store_Audit_Item__c>>> saisByCustKeyBySAid = new Map<Id, Map<String, List<EUR_CRM_Store_Audit_Item__c>>>();

			for (EUR_CRM_Store_Audit_Item__c sai : sais) {
				String saiCustKey = this.getSAIcustKey(sai);
				if (saisByCustKeyBySAid.containsKey(sai.EUR_CRM_Store_Audit__c)) {
					if (saisByCustKeyBySAid.get(sai.EUR_CRM_Store_Audit__c).containsKey(saiCustKey)) {
						saisByCustKeyBySAid.get(sai.EUR_CRM_Store_Audit__c).get(saiCustKey).add(sai);
					}
					else {
						saisByCustKeyBySAid.get(sai.EUR_CRM_Store_Audit__c).put
							(saiCustKey, new List<EUR_CRM_Store_Audit_Item__c>{ sai });
					}
				} else {
					saisByCustKeyBySAid.put(
						sai.EUR_CRM_Store_Audit__c, new Map<String, List<EUR_CRM_Store_Audit_Item__c>>{
							saiCustKey => new List<EUR_CRM_Store_Audit_Item__c>{ sai }
						});
				}
			}

			return saisByCustKeyBySAid;
		}

		private List<EUR_CRM_Store_Audit_Item__c> getSaisToDelete(Map<Id, Map<String, List<EUR_CRM_Store_Audit_Item__c>>> saisByCustKeyBySaId) {
			List<EUR_CRM_Store_Audit_Item__c> saisToDelete = new List<EUR_CRM_Store_Audit_Item__c>();
			for (Id saId : saisByCustKeyBySaId.keySet()) {
				Map<String, List<EUR_CRM_Store_Audit_Item__c>> saisByCustKey = saisByCustKeyBySaId.get(saId);
				for (String custKey : saisByCustKey.keySet()) {
					List<EUR_CRM_Store_Audit_Item__c> sais = saisByCustKey.get(custKey);
					if (sais.size() <= 1) { continue; }
					saisToDelete.addAll(this.getSAIsExceptOne(sais));
				}
			}
			return saisToDelete;
		}

		private List<EUR_CRM_Store_Audit_Item__c> getSAIsExceptOne(List<EUR_CRM_Store_Audit_Item__c> sais) {
			for (Integer i = 0; i < sais.size(); i++) {
				EUR_CRM_Store_Audit_Item__c sai = sais[i];
				if (sai.EUR_CRM_Mobile_ID__c != null) {
					sais.remove(i);
					return sais;
				}
			}
			sais.remove(0);
			return sais;
		}

		private String getSAIcustKey(EUR_CRM_Store_Audit_Item__c sai) {
			return sai.EUR_CRM_Brand__c + '' +
				sai.EUR_CRM_Brand_Quality__c + '' +
				sai.EUR_CRM_Brand_Quality_Size__c + '' +
				sai.EUR_CRM_GB_Brand_Quality__c;
		}
	}


	//High level helpers
	@TestVisible
	private String buildSaisQueryRegardlessMobileId(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
		String query = 'SELECT Id ' +
			' , EUR_CRM_Brand_Quality_Size__c ' +
			' , EUR_CRM_Brand_Quality__c ' +
			' , EUR_CRM_Brand__c ' +
			' , EUR_CRM_GB_Brand_Quality__c ' +
			' , EUR_CRM_Mobile_ID__c ' +
			' , EUR_CRM_Store_Audit__c ' +
			' FROM EUR_CRM_Store_Audit_Item__c ' +
			' WHERE ' +
			' (EUR_CRM_Brand_Quality_Size__c != NULL ' +
			' OR EUR_CRM_Brand_Quality__c != NULL ' +
			' OR EUR_CRM_Brand__c != NULL ' +
			' OR EUR_CRM_GB_Brand_Quality__c != NULL) ' +
			' AND RecordType.DeveloperName IN :rtDevNames ' +
			(startDatetime == null ? '' : ' AND EUR_CRM_Store_Audit__r.CreatedDate >= :startDatetime ') +
			(endDatetime == null ? '' : ' AND EUR_CRM_Store_Audit__r.CreatedDate < :endDatetime ') +
			' ORDER BY EUR_CRM_Store_Audit__c, EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand__c, EUR_CRM_GB_Brand_Quality__c'
		;

		System.debug('\n sais query regardless Mobile Id => ' + query + '\n');
		return query;
	}

	private  static List<CronTrigger> selectCronTriggers() {
		return [
			SELECT Id
				,   CronJobDetail.Name
				,   CronExpression
				,   NextFireTime
			FROM CronTrigger
			WHERE CronJobDetail.Name LIKE :EUR_CRM_STORE_AUDIT_ITEMS_DUPLICATE_CLEAN + '%'
		];
	}

}