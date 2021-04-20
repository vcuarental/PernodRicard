global class EUR_CRM_DE_ScheduleDeactivateOP implements Schedulable{

    public static String sched = '0 00 02 * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Deactivate OP-Account Mapping Records';
    public static String JOB_NAME_RETRY = 'Deactivate OP-Account Mapping Records'; 
    public static String dtFormat=  's m H d M \'?\' yyyy' ; 
    
    global static String schedule() {
        EUR_CRM_DE_ScheduleDeactivateOP  SC = new EUR_CRM_DE_ScheduleDeactivateOP(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_DE_DeactivateOPAccountMappings  b1 = new EUR_CRM_DE_DeactivateOPAccountMappings();
            Id batchprocessid = Database.executeBatch(b1,150);  
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_DE_ScheduleDeactivateOP scRetry = new EUR_CRM_DE_ScheduleDeactivateOP();
            Datetime dt= Datetime.now() + (0.00138);
            Id schedId = System.Schedule(JOB_NAME_RETRY,dt.format(dtFormat),scRetry);
        } 
               
    }
}