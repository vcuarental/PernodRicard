global class EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping implements Schedulable {
    
    public static String sched = '0 00 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'ZA Nightly OP Account Mappings Batch Files';
    public static String JOB_NAME_RETRY = 'ZA Nightly OP Account Mappings Batch Files Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    global static String schedule() {
        EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping  SC = new EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] <= 1){
            // All nightly Op Mappings related batch files 
            EUR_CRM_ZA_MassActivateOPAccountMapping activationBatch = new EUR_CRM_ZA_MassActivateOPAccountMapping();
            EUR_CRM_ZA_MassUpdateOPAccountMapping inactivationBatch = new EUR_CRM_ZA_MassUpdateOPAccountMapping();
            EUR_CRM_ZA_CreateVisitActionFollowUps followUpVisitsBatch = new EUR_CRM_ZA_CreateVisitActionFollowUps();
            EUR_CRM_ZA_MassUpdOPAcctTermination terminationBatch = new EUR_CRM_ZA_MassUpdOPAcctTermination();
            // run the batch files
            Database.executebatch(activationBatch, 200);
            Database.executebatch(inactivationBatch, 200);
            Database.executebatch(followUpVisitsBatch, 200);
            Database.executebatch(terminationBatch, 200);
        }
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping  scRetry = new EUR_CRM_ZA_ScheduledMassUpdOPAcctMapping(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }
    }
}