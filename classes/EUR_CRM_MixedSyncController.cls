public with sharing class EUR_CRM_MixedSyncController implements Schedulable{

	@TestVisible
	private static final String PACKAGE_SCHEDULERS_NAME_TEMPLATE = 'CT Check Retrieve Status';
	private static final String APEX_CLASS_NAME = 'Schedule_CheckRetrieveStatus';
	private static final String CHECKER_SCHEDULER_NAME = 'JOBS CHECKER';

	private static EUR_CRM_MixedSyncController thisInstance = new EUR_CRM_MixedSyncController();
	@AuraEnabled
	public static String runScript() {
		if ( !Test.isRunningTest() && !selectCronTriggersWhereNameLike(PACKAGE_SCHEDULERS_NAME_TEMPLATE).isEmpty()) { return 'Already'; }

		List<clm__ApplicationSetup__c> listDates = selectApplicationSetups();
		for(clm__ApplicationSetup__c aps : listDates) {
			aps.clm__MetadataLastModifiedDate__c = null;
		}
		update listDates;
		if ( ! Test.isRunningTest()) {
			clm.Schedule_LastModifiledDate.doCalloutFromFuture();
		}
		thisInstance.scheduleNewChecker(CHECKER_SCHEDULER_NAME);
		return 'Success';

	}


	public void scheduleNewChecker(String jobName) {
		this.abortJobs(selectCronTriggersWhereNameLike(jobName));
		String second = String.valueOf(Datetime.now().second());
		String min = String.valueOf(Datetime.now().addMinutes(5).minute());
		String nextFireTime = second + ' ' + min + ' * * * ?';
		System.schedule(jobName, nextFireTime, this);
	}

	private void abortJobs(List<CronTrigger> cronTriggers) {
		for (CronTrigger ct : cronTriggers) {
			System.abortJob(ct.Id);
		}
	}

	public void execute(SchedulableContext sc) {
		if (this.isNeedToRunChecker()) {
			this.scheduleNewChecker(CHECKER_SCHEDULER_NAME);
			return;
		}
		this.abortJobs(selectCronTriggersWhereNameLike(PACKAGE_SCHEDULERS_NAME_TEMPLATE));
		this.abortJobs(selectCronTriggersWhereNameLike(CHECKER_SCHEDULER_NAME));
		this.sendEmailReport();
	}

	@TestVisible
	private Boolean isNeedToRunChecker() {
		return this.isValidCronTriggersExists(PACKAGE_SCHEDULERS_NAME_TEMPLATE) || this.isValidAsyncApexJobExists(APEX_CLASS_NAME);
	}

	private Boolean isValidCronTriggersExists(String name) {
		List<CronTrigger> validCronTriggers = new List<CronTrigger>();
		for (CronTrigger ct : selectCronTriggersWhereNameLike(name)) {
			if ( ! this.isNextFireWithinSpecifiedHour(2, ct)) { continue; }
			validCronTriggers.add(ct);
		}
		return ! validCronTriggers.isEmpty();
	}

	private Boolean isValidAsyncApexJobExists(String apexClassName) {
		return ! selectAsyncApexJobs(apexClassName).isEmpty();
	}

	private Boolean isNextFireWithinSpecifiedHour(Integer hour, CronTrigger ct) {
		Datetime dateTimeNow = Datetime.now();
		return ct.NextFireTime.day() == dateTimeNow.day() &&
			ct.NextFireTime.time() <= dateTimeNow.addHours(hour).time();
	}

	private void sendEmailReport() {
		String messageText = '\nPackage for mobile has already created\n';
		String subject = 'Package created';

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setToAddresses(new List<String> { UserInfo.getUserEmail() });
		message.setSubject(subject);
		message.setPlainTextBody(messageText);

		if ( ! Test.isRunningTest()) {
			try {
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
			} catch (Exception e) {
				System.debug('\n\n e.getMessage() => ' + e.getMessage() + '\n');
			}
		}
	}

	private static List<CronTrigger> selectCronTriggersWhereNameLike(String nameTemplate) {
		return [
			SELECT Id, NextFireTime
			FROM CronTrigger
			WHERE CronJobDetail.Name LIKE :nameTemplate + '%'
		];
	}

	@TestVisible
	private static List<clm__ApplicationSetup__c> selectApplicationSetups() {
		return [
			SELECT Id
			,   clm__MetadataLastModifiedDate__c
			FROM clm__ApplicationSetup__c
			LIMIT 50000];
	}

	private static List<AsyncApexJob> selectAsyncApexJobs(String name) {
		return [
			SELECT Id
			FROM AsyncApexJob
			WHERE JobType IN ('Future')
			AND Status IN ('Queued', 'Processing')
			AND ApexClass.Name = :name
		];
	}
}