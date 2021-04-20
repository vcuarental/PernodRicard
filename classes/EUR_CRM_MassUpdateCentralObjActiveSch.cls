global with sharing class EUR_CRM_MassUpdateCentralObjActiveSch implements Schedulable{
    public static String sched = '0 00 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Daily batch FOR EUR_CRM_MassUpdateCentralObjActive';
    public static String JOB_NAME_RETRY = 'Daily batch FOR EUR_CRM_MassUpdateCentralObjActive Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] <= 4){
            // Daily batch to Mass Update EM import Objective
            EUR_CRM_MassUpdateCentralObjActive scheduleJob = new EUR_CRM_MassUpdateCentralObjActive();
            // run the batch file and reschedule
            Database.executebatch(scheduleJob);
        }
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_MassUpdateCentralObjActiveSch scRetry = new EUR_CRM_MassUpdateCentralObjActiveSch(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }
    }
}