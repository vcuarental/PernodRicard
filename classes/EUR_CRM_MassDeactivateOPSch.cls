global class EUR_CRM_MassDeactivateOPSch implements Schedulable{

    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Mass Deactivate BE OP';
    public static String JOB_NAME_RETRY = 'MMass Deactivate BE OP Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_MassDeactivateOP b1 = new EUR_CRM_MassDeactivateOP();
            Id batchprocessid = Database.executeBatch(b1,50);  
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_MassDeactivateOPSch  scRetry = new EUR_CRM_MassDeactivateOPSch(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }         
    }
}