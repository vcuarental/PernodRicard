global class EUR_CRM_FI_ScheduleVisitActionFollowUp implements Schedulable{

    public static String sched = '0 03 00 * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Create Finland Visit Follow Ups';
    public static String JOB_NAME_RETRY = 'Create Finland Visit Follow Ups';
    public static String dtFormat=  's m H d M \'?\' yyyy' ; 
    
    global static String schedule() {
        List<CronTrigger> cronTriggers = selectScheduledJobs();
        if ( ! cronTriggers.isEmpty()) { removeScheduledJobs(cronTriggers); }
        EUR_CRM_FI_ScheduleVisitActionFollowUp  SC = new EUR_CRM_FI_ScheduleVisitActionFollowUp ();
        return System.schedule(JOB_NAME, sched, SC);
    }

    global void execute(SchedulableContext sc) {

        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_FI_CreateVisitActionFollowUps b1 = new EUR_CRM_FI_CreateVisitActionFollowUps();
            Id batchprocessid = Database.executeBatch(b1,50);  
        } 
        else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_FI_ScheduleVisitActionFollowUp scRetry = new EUR_CRM_FI_ScheduleVisitActionFollowUp ();
            Datetime dt= Datetime.now() + (0.00138);
            Id schedId = System.Schedule(JOB_NAME_RETRY,dt.format(dtFormat),scRetry);
        } 
               
    }

    private static void removeScheduledJobs(List<CronTrigger> cronTriggers) {
        for (CronTrigger cronTrigger : cronTriggers) {
            System.debug('\n cronTrigger.Id => ' + cronTrigger.Id + ' ' + cronTrigger.CronJobDetail.Name + '\n');
            System.abortJob(cronTrigger.Id);
        }
    }

    private static List<CronTrigger> selectScheduledJobs() {
        return [
            SELECT
                Id,
                CronJobDetail.Name,
                CronExpression,
                CronJobDetailId,
                EndTime,
                NextFireTime
            FROM CronTrigger
            Where CronJobDetail.Name Like :(JOB_NAME + '%')
            OR CronJobDetail.Name Like :(JOB_NAME_RETRY + '%')
        ];
    }
}