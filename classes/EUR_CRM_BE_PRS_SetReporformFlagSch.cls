global class EUR_CRM_BE_PRS_SetReporformFlagSch implements Schedulable{
    public static String sched = '0 00 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Yearly Reporform PRS for BE';
    public static String JOB_NAME_RETRY = 'Yearly Reporform PRS for BE - Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    global static String schedule() {
        EUR_CRM_BE_PRS_SetReporformFlagSch  SC = new EUR_CRM_BE_PRS_SetReporformFlagSch(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_BE_PRS_SetReperformFlag b1 = new EUR_CRM_BE_PRS_SetReperformFlag ();
            Id batchprocessid = Database.executeBatch(b1,50);  
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_BE_PRS_SetReporformFlagSch scRetry = new EUR_CRM_BE_PRS_SetReporformFlagSch(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        } 
               
    }
}