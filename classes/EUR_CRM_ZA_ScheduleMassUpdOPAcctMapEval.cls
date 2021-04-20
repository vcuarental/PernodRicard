global class EUR_CRM_ZA_ScheduleMassUpdOPAcctMapEval implements Schedulable{
    public static String sched = '0 0 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'ZA OP Visit Actions Eval Batch';
    public static String JOB_NAME_RETRY = 'ZA OP Visit Actions Eval Batch Retry';
    public static Datetime dt = Datetime.now() + 60;
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 

    global static void schedule() {
        //schedule this same schedulable class again in 30 mins
        EUR_CRM_ZA_ScheduleMassUpdOPAcctMapEval scheduler = new EUR_CRM_ZA_ScheduleMassUpdOPAcctMapEval(); 
        Id schedId = System.Schedule(JOB_NAME+timeForScheduler, sched, scheduler);
    }

    global void execute(SchedulableContext sc) {
        if ([SELECT count() FROM AsyncApexJob WHERE JobType =: JOBTYPE AND (Status =: STATUS_PROCESSING OR Status =: STATUS_PREPARING)] < 5){
            // ZA OP Visit Actions Eval Batch
            EUR_CRM_ZA_MassUpdateOPAcctMapEval b = new EUR_CRM_ZA_MassUpdateOPAcctMapEval(); 
            // run the batch files
            Database.executebatch(b, 200);
        }
    }
}