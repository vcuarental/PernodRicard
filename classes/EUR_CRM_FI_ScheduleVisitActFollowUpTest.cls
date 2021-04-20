@IsTest
private class EUR_CRM_FI_ScheduleVisitActFollowUpTest {

	@IsTest
	private static void runOneSchedule() {

		Test.startTest();
		String cronJobId = EUR_CRM_FI_ScheduleVisitActionFollowUp.schedule();
		Test.stopTest();

		List<CronTrigger> cronTriggers = selectCronTriggers(new Set<String>{ cronJobId });
		System.assertEquals(1, cronTriggers.size());
		System.assertEquals('0 03 00 * * ?', cronTriggers[0].CronExpression);
	}

	@IsTest
	private static void runSeveralSchedules() {

		Test.startTest();
		String cron1 = EUR_CRM_FI_ScheduleVisitActionFollowUp.schedule();
		String cron2 = EUR_CRM_FI_ScheduleVisitActionFollowUp.schedule();
		Test.stopTest();

		List<CronTrigger> cronTriggers = selectCronTriggers(new Set<String>{ cron1, cron2 });
		System.assertEquals(1, cronTriggers.size());
		System.assertEquals('0 03 00 * * ?', cronTriggers[0].CronExpression);
	}

	private static List<CronTrigger> selectCronTriggers(Set<String> cronJobIds) {
		return [
			SELECT Id
				,   CronJobDetail.Name
				,   CronExpression
				,   NextFireTime
			FROM CronTrigger
			WHERE Id IN :cronJobIds
		];
	}
}