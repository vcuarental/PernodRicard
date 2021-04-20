global with sharing class EUR_CRM_ScheduleRUAccrueAchievements implements Schedulable{
    public static String sched = '0 00 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Hourly batch to accrue RU achievements';
    public static String JOB_NAME_RETRY = 'Hourly batch to accrue RU achievements Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] <= 4){
            // Hourly batch to accrue RU achievements
            EUR_CRM_RU_AccrueAchievements accrueBatch = new EUR_CRM_RU_AccrueAchievements();
            // run the batch file and reschedule
            Database.executebatch(accrueBatch, 200);
        }
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_ScheduleRUAccrueAchievements scRetry = new EUR_CRM_ScheduleRUAccrueAchievements(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }
    }
}