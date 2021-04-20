public with sharing class EUR_CRM_VisitDuplicateClean extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable, Database.Stateful{

	@TestVisible
	private static final String EUR_CRM_VISIT_DUPLICATE_CLEAN = 'EUR_CRM_VisitDuplicateClean';

	private List<Id> accIds;
	private Set<String> countryCodes;
	private Datetime startDatetime;
	private Datetime endDatetime;
	private Integer batchSize = 200;
	private final Boolean queryVisitsWithMobileId;

	private static final Set<String> CHILDREN_TO_CHECK = new Set<String>{
		'Store_Audits__r'
	,	'Price_Check_EU__r'
	,	'POSM_Audit_EU__r'
	,	'EUR_CRM_Contract_Audits__r'
	,	'Fair_Share_EU__r'
	,	'Competitor_Promo_Tracking_EU__r'
	,	'Contracts_Tracker_EU__r'
	,	'Brand_Security_Infringements__r'
	,   'EUR_CRM_Visit_Actions__r'
	};

	//Schedule interfaces
	/*
	* Cron expression example:
	* Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
	* String cronExpr = '0 0 1 * * ?'; Class runs every day at 1 AM.
	*/
	public static String scheduleCleanRecordsWhereCountryCodesAndDates(String cronExpression, Set<String> countryCodes, Datetime startDatetime, Datetime endDatetime, Boolean queryVisitsWithMobileId, Integer batchSize) {
		return System.schedule(
			EUR_CRM_VISIT_DUPLICATE_CLEAN + ' at ' + cronExpression,
			cronExpression,
			new EUR_CRM_VisitDuplicateClean(countryCodes, startDatetime, endDatetime, queryVisitsWithMobileId, batchSize)
		);
	}

	public static void removeSchedules() {
		List<CronTrigger> cronTriggers = selectCronTriggers();
		for(CronTrigger ct : cronTriggers) {
			System.abortJob(ct.Id);
		}
	}


	//Batch Interfaces
	public static void cleanRecordsWhereAccountIds(List<Id> accIds, Boolean queryVisitsWithMobileId) {
		Database.executeBatch(new EUR_CRM_VisitDuplicateClean(accIds, queryVisitsWithMobileId));
	}

	public static void cleanRecordsWhereCountryCodes(Set<String> countryCodes, Boolean queryVisitsWithMobileId) {
		Database.executeBatch(new EUR_CRM_VisitDuplicateClean(countryCodes, queryVisitsWithMobileId));
	}

	public static void cleanRecordsWhereCountryCodes(Set<String> countryCodes, Boolean queryVisitsWithMobileId, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_VisitDuplicateClean(countryCodes, queryVisitsWithMobileId), batchSize);
	}

	public static void cleanRecordsWhereCountryCodesAndDates(Set<String> countryCodes, Datetime startDatetime, Datetime endDatetime, Boolean queryVisitsWithMobileId) {
		Database.executeBatch(new EUR_CRM_VisitDuplicateClean(countryCodes, startDatetime, endDatetime, queryVisitsWithMobileId));
	}

	public static void cleanRecordsWhereCountryCodesAndDates(Set<String> countryCodes, Datetime startDatetime, Datetime endDatetime, Boolean queryVisitsWithMobileId, Integer batchSize) {
		Database.executeBatch(new EUR_CRM_VisitDuplicateClean(countryCodes, startDatetime, endDatetime, queryVisitsWithMobileId), batchSize);
	}



	//Constructors
	public EUR_CRM_VisitDuplicateClean(List<Id> accIds, Boolean queryVisitsWithMobileId) {
		this.accIds = accIds;
		this.queryVisitsWithMobileId = queryVisitsWithMobileId;
	}

	public EUR_CRM_VisitDuplicateClean(Set<String> countryCodes, Boolean queryVisitsWithMobileId) {
		this.countryCodes = countryCodes;
		this.queryVisitsWithMobileId = queryVisitsWithMobileId;
	}

	public EUR_CRM_VisitDuplicateClean(Set<String> countryCodes, Datetime startDatetime, Datetime endDatetime, Boolean queryVisitsWithMobileId) {
		this.countryCodes = countryCodes;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
		this.queryVisitsWithMobileId = queryVisitsWithMobileId;
	}

	public EUR_CRM_VisitDuplicateClean(Set<String> countryCodes, Datetime startDatetime, Datetime endDatetime, Boolean queryVisitsWithMobileId, Integer batchSize) {
		this.countryCodes = countryCodes;
		this.startDatetime = startDatetime;
		this.endDatetime = endDatetime;
		this.queryVisitsWithMobileId = queryVisitsWithMobileId;
		this.batchSize = batchSize;
	}

	//Schedulable
	public void execute(SchedulableContext sc) {
		Database.executeBatch( this, this.batchSize );
	}


	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator( this.buildStartQuery() );
	}

	public void execute(Database.BatchableContext bc, List<EUR_CRM_Visit__c> visits) {
		List<EUR_CRM_Visit__c> visitsToDelete = new Service(this.queryVisitsWithMobileId).getVisitsToDelete(visits);
		System.debug('\n visitsToDelete.size() => ' + visitsToDelete.size() + '\n');
		System.debug('\n visitsToDelete => ' + JSON.serializePretty(visitsToDelete) + '\n');
		this.deleteRecords(visitsToDelete);
	}

	@TestVisible
	private String buildStartQuery() {
		if (this.queryVisitsWithMobileId) { return this.buildQueryWithMobileId(); }
		return this.buildQueryWithoutMobileId();
	}

	private String buildQueryWithMobileId() {
		String query = 'SELECT Id ' +
			' , EUR_CRM_Account__c ' +
			' , EUR_CRM_Mobile_ID__c ' +
			' FROM EUR_CRM_Visit__c ' +
			' WHERE ' +
			' EUR_CRM_Mobile_ID__c != NULL ' +
			' AND EUR_CRM_Account__c != NULL ' +
			(this.accIds == null ? '' : ' AND EUR_CRM_Account__c IN :accIds ') +
			(this.countryCodes == null ? '' : ' AND EUR_CRM_Country_Code__c IN :countryCodes ') +
			(this.startDatetime == null ? '' : ' AND CreatedDate >= :startDatetime ') +
			(this.endDatetime == null ? '' : ' AND CreatedDate < :endDatetime ') +
			' ORDER BY EUR_CRM_Mobile_ID__c ';
		System.debug('\n visit query (with mobile Id) => ' + query + '\n');
		return query;
	}

	private String buildQueryWithoutMobileId() {
		String query = 'SELECT Id ' +
			' , EUR_CRM_Account__c ' +
			' , EUR_CRM_Start_Datetime__c ' +
			' , EUR_CRM_End_Datetime__c ' +
			' FROM EUR_CRM_Visit__c ' +
			' WHERE ' +
			' EUR_CRM_Mobile_ID__c = NULL ' +
			' AND EUR_CRM_Account__c != NULL ' +
			(this.accIds == null ? '' : ' AND EUR_CRM_Account__c IN :accIds ') +
			(this.countryCodes == null ? '' : ' AND EUR_CRM_Country_Code__c IN :countryCodes ') +
			(this.startDatetime == null ? '' : ' AND CreatedDate >= :startDatetime ') +
			(this.endDatetime == null ? '' : ' AND CreatedDate < :endDatetime ') +
			' ORDER BY EUR_CRM_Account__c, EUR_CRM_Start_Datetime__c DESC , EUR_CRM_End_Datetime__c DESC ';
		System.debug('\n visit query (without mobile Id)=> ' + query + '\n');
		return query;
	}


	private static List<CronTrigger> selectCronTriggers() {
		return [
			SELECT Id
				,   CronJobDetail.Name
				,   CronExpression
				,   NextFireTime
			FROM CronTrigger
			WHERE CronJobDetail.Name LIKE :EUR_CRM_VISIT_DUPLICATE_CLEAN + '%'
		];
	}

	//Service
	public class Service {
		private final Boolean isQueryVisitsWithMobileId;
		public Service(Boolean isQueryVisitsWithMobileId) {
			this.isQueryVisitsWithMobileId = isQueryVisitsWithMobileId;
		}
		public List<EUR_CRM_Visit__c> getVisitsToDelete(List<EUR_CRM_Visit__c> visits) {
			//get count of each child for each visit
			Map<Id, List<ChildWrapper>> childWrappersByVisitId = this.getChildWrappersByVisitId(visits);

			//get only duplicated groupings by EUR_CRM_Account__c + '_' + EUR_CRM_Mobile__Id__c
			Map<String, List<VisitWrapper>> duplVisitWrappersByCustKey = this.getDuplVisitWrappersByCustKey(this.getVisitWrappersByCustKey(visits));

			//populate Visit Wrappers with children size for each child
			this.populateVisitWrappers(duplVisitWrappersByCustKey, childWrappersByVisitId);

			return this.getVisitsToDelete(duplVisitWrappersByCustKey);
		}


		private Map<Id, List<ChildWrapper>> getChildWrappersByVisitId(List<EUR_CRM_Visit__c> visits) {
			Map<Id, List<ChildWrapper>> childWrappersByVisitId = new Map<Id, List<ChildWrapper>>();

			//build QueryWrappers to get Visits children
			List<QueryWrapper> queryWrappers = this.buildChildQueries();
			for (QueryWrapper qw : queryWrappers) {
				List<AggregateResult> ars = Database.query(qw.query);
				//populate QW query results
				qw.aggregateResults = ars;
			}

			for (QueryWrapper qw : queryWrappers) {
				for (AggregateResult ar : qw.aggregateResults) {
					Id visitId = (Id) ar.get(qw.parentField);
					Integer childCount = (Integer) ar.get('children');
					ChildWrapper chW = new ChildWrapper(qw.childRelName, childCount);

					if (childWrappersByVisitId.containsKey(visitId)) {
						childWrappersByVisitId.get(visitId).add(chW);
					} else {
						childWrappersByVisitId.put(visitId, new List<ChildWrapper>{ chW });
					}
				}
			}
			return childWrappersByVisitId;
		}

		private List<QueryWrapper> buildChildQueries() {
			List<QueryWrapper> queryWrappers = new List<QueryWrapper>();
			List<ChildRelationship> childRelationships = EUR_CRM_Visit__c.SObjectType.getDescribe().getChildRelationships();

			for (ChildRelationship chr : childRelationships) {
				if ( ! CHILDREN_TO_CHECK.contains(chr.getRelationshipName())) { continue; }
				String sobjType = chr.getChildSObject().getDescribe().getName();
				String field = chr.getField().getDescribe().getName();
				queryWrappers.add(new QueryWrapper(sobjType, chr.getRelationshipName(), field));
			}
			return queryWrappers;
		}

		private List<VisitWrapper> getVisitWrappers(List<EUR_CRM_Visit__c> visits) {
			List<VisitWrapper> visitWrappers = new List<VisitWrapper>();
			for (EUR_CRM_Visit__c v : visits) {
				visitWrappers.add(new VisitWrapper(v));
			}
			return visitWrappers;
		}

		private Map<String, List<VisitWrapper>> getVisitWrappersByCustKey(List<EUR_CRM_Visit__c> visits) {
			List<VisitWrapper> visitWrappers = this.getVisitWrappers(visits);

			Map<String, List<VisitWrapper>> visitsByCustKey = new Map<String, List<VisitWrapper>>();
			for (VisitWrapper vw : visitWrappers) {
				String custKey = this.getCustKey(vw.visit);
				System.debug('\n custKey => ' + custKey + '\n');
				if (visitsByCustKey.containsKey(custKey)) {
					visitsByCustKey.get(custKey).add(vw);
				} else {
					visitsByCustKey.put(custKey, new List<VisitWrapper>{ vw });
				}
			}
			return visitsByCustKey;
		}

		private Map<String, List<VisitWrapper>> getDuplVisitWrappersByCustKey(Map<String, List<VisitWrapper>> visitWrappsByCustKey) {
			for (String custKey : visitWrappsByCustKey.keySet()) {
				List<VisitWrapper> vWrapps = visitWrappsByCustKey.get(custKey);
				if (vWrapps.size() <= 1) {
					visitWrappsByCustKey.remove(custKey);
				}
			}
			return visitWrappsByCustKey;
		}

		private void populateVisitWrappers(Map<String, List<VisitWrapper>> visitWrappersByCustKey, Map<Id, List<ChildWrapper>> childWrappersByVisitId) {
			for (String custKey : visitWrappersByCustKey.keySet()) {
				List<VisitWrapper> visitWrappers = visitWrappersByCustKey.get(custKey);
				for (VisitWrapper vw : visitWrappers) {
					List<ChildWrapper> chWrapps = childWrappersByVisitId.get(vw.visit.Id);
					if (chWrapps == null) { continue; }
					vw.childWrappers.addAll(chWrapps);
				}
			}
		}

		private List<EUR_CRM_Visit__c> getVisitsToDelete(Map<String, List<VisitWrapper>> visitWrappersByCustKey) {
			List<EUR_CRM_Visit__c> visitsToDelete = new List<EUR_CRM_Visit__c>();
			for (String custKey : visitWrappersByCustKey.keySet()) {
				List<VisitWrapper> vws = visitWrappersByCustKey.get(custKey);
				List<EUR_CRM_Visit__c> tmpVs = new List<EUR_CRM_Visit__c>();
				for (VisitWrapper vw : vws) {
					if ( ! vw.childWrappers.isEmpty()) { continue; }
					tmpVs.add(vw.visit);
				}
				if (tmpVs.size() == vws.size()) { tmpVs.remove(0); }
				visitsToDelete.addAll(tmpVs);
			}
			return visitsToDelete;
		}

		private String getCustKey(EUR_CRM_Visit__c v) {
			if (this.isQueryVisitsWithMobileId) { return this.getCustKeyWithMobileId(v); }
			return this.getCustKeyWithoutMobileId(v);
		}

		private String getCustKeyWithMobileId(EUR_CRM_Visit__c v) {
			return v.EUR_CRM_Account__c + '_' + v.EUR_CRM_Mobile_ID__c;
		}

		private String getCustKeyWithoutMobileId(EUR_CRM_Visit__c v) {
			return v.EUR_CRM_Account__c + '_' + v.EUR_CRM_Start_Datetime__c + '_' + v.EUR_CRM_End_Datetime__c;
		}
	}


	//Wrappers
	public class VisitWrapper {
		public EUR_CRM_Visit__c visit;
		public List<ChildWrapper> childWrappers;

		public VisitWrapper(EUR_CRM_Visit__c visit) {
			this.visit = visit;
			this.childWrappers = new List<ChildWrapper>();
		}
	}

	public class ChildWrapper {
		public String childRelName;
		public Integer size;

		public ChildWrapper(String childRelName, Integer size) {
			this.childRelName = childRelName;
			this.size = size;
		}
	}

	public class QueryWrapper {
		public String sobjType;
		public String childRelName;
		public String parentField;
		public String query;
		public List<AggregateResult> aggregateResults;

		public QueryWrapper(String sobjType, String childRelName, String parentField) {
			this.sobjType = sobjType;
			this.childRelName = childRelName;
			this.parentField = parentField;
			this.query = this.buildChildQuery(parentField, sobjType);
			this.aggregateResults = new List<AggregateResult>();
		}

		public String buildChildQuery(String parentField, String sobjType) {
			return ' SELECT ' + parentField + ' , COUNT(Id) children' +
				' FROM ' + sobjType +
				' WHERE ' + parentField + ' IN :visits' +
				' GROUP BY ' + parentField
				;
		}
	}

}