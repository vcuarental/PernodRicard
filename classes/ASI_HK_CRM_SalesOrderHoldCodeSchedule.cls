public without sharing class ASI_HK_CRM_SalesOrderHoldCodeSchedule implements Schedulable {
	
	public static final Integer SECONDS_TO_WAIT = 40; //Edit by Introv 20131206 Shorten Time Period 
	private static final String JOB_NAME = 'ASI_HK_CRM_SalesOrderHoldCodeSchedule';
	private static final Set<String> SCHDEULE_JOB_STATUS_PENDING = new Set<String> {
		'WAITING'
		, 'ACQUIRED'
		, 'EXECUTING' 
	};
	
	public static void schedule() {
		schedule(SECONDS_TO_WAIT);
	}
	public static void schedule(Integer secondsToWait) {
		String cronExprLike = '% ' + JOB_NAME;
		System.debug('sohcs01' + cronExprLike + ';Running User:' + UserInfo.getName()  );
		List<CronTrigger> scheduleJobs = [SELECT Id, State FROM CronTrigger WHERE CronExpression LIKE :cronExprLike and OwnerId =:UserInfo.getUserId()];
		Boolean hasJobPending = false;
		//Edit by Introv 20131206 Abort all success job, job pending only apply for same owner
		System.debug('sohcs02 job no:' + scheduleJobs.size()  );
		for (CronTrigger scheduleJob: scheduleJobs) {
			if (SCHDEULE_JOB_STATUS_PENDING.contains(scheduleJob.State))
				hasJobPending = true;
			else
				System.abortJob(scheduleJob.Id);
		}
		System.debug('sohcs03 job pending:' + hasJobPending  );
		if (!hasJobPending) {
			System.schedule(
				JOB_NAME + '_' + UserInfo.getName()
				, cronExpressionForSecondsAfter(secondsToWait) + ' ' + JOB_NAME
				, new ASI_HK_CRM_SalesOrderHoldCodeSchedule()
			);
		}
	}
	
	public void execute(SchedulableContext ctx) {
		ASI_HK_CRM_SalesOrderHoldCodeRequest.executeBatch();
	}
	
	private static String cronExpressionForSecondsAfter(Integer seconds){
		Datetime targetDT = System.now().addSeconds(seconds);
		String cronExpression = String.format('{0} {1} {2} {3} {4} ? {5}' , new String[]{
			String.valueOf(targetDT.second())
			, String.valueOf(targetDT.minute())
			, String.valueOf(targetDT.hour())
			, String.valueOf(targetDT.day())
			, String.valueOf(targetDT.month())
			, String.valueOf(targetDT.year())
		});
		return cronExpression;
	}
}