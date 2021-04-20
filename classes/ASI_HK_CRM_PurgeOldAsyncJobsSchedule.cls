//20140623 Steve Wan

global class ASI_HK_CRM_PurgeOldAsyncJobsSchedule implements Schedulable {
  global void execute(SchedulableContext sc) {
      Integer count = System.purgeOldAsyncJobs(Date.today()-3);
      System.debug('Deleted ' + count + ' old jobs.');
  }
}