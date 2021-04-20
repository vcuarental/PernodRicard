global class EUR_CRM_FI_ScheduleAccrueAchievements implements Schedulable{

    public static String sched = '0 00 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Accrue Finland Objective Achievements';
    public static String JOB_NAME_RETRY = 'Accrue Finland Objective Achievements Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    global static String schedule() {
        EUR_CRM_FI_ScheduleAccrueAchievements SC = new EUR_CRM_FI_ScheduleAccrueAchievements(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_FI_AccrueAchievements b1 = new EUR_CRM_FI_AccrueAchievements ();
            Id batchprocessid = Database.executeBatch(b1,50);  
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_FI_ScheduleAccrueAchievements scRetry = new EUR_CRM_FI_ScheduleAccrueAchievements  (); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        } 
               
    }
}