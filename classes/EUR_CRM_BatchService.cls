// Works only on 32.0 version
public without sharing class EUR_CRM_BatchService implements Schedulable {

    private static final Integer SCHEDULE_MINUTES_FROM_NOW;
    private static final Integer BATCH_WAITING_MINUTES_FROM_NOW;

    static {
        SCHEDULE_MINUTES_FROM_NOW = 2;
        BATCH_WAITING_MINUTES_FROM_NOW = 5;
    }

    private static final Set<String> RUNING_JOB_STATUSES = new Set<String> {
        'Holding', 'Queued', 'Preparing', 'Processing'
    };

    private static final Set<String> RUNING_CRON_TRIGGER_STATUSES = new Set<String> {
        'WAITING', 'ACQUIRED', 'EXECUTING', 'PAUSED'
    };

    private Database.Batchable<sObject> batchable;
    private Integer scopeSize;
    private String jobName;

    public EUR_CRM_BatchService(Database.Batchable<sObject> batchable, Integer scopeSize, String jobName) {
        this.batchable = batchable;
        this.scopeSize = scopeSize;
        this.jobName = jobName;
    }

    public void execute(SchedulableContext ctx) {
        abortOldJobs();
        abortJob(ctx.getTriggerId());

        if(isRuningBatch(batchable)) {
            scheduleBatch(batchable, scopeSize, BATCH_WAITING_MINUTES_FROM_NOW, jobName);
        } else {
            Database.executeBatch(batchable, scopeSize);
        }
    }

    public static void scheduleBatch(Database.Batchable<sObject> batchable, Integer scopeSize) {
        scheduleBatch(batchable, scopeSize, SCHEDULE_MINUTES_FROM_NOW, null);
    }

    public static void scheduleBatch(Database.Batchable<sObject> batchable, Integer scopeSize, String name) {
        scheduleBatch(batchable, scopeSize, SCHEDULE_MINUTES_FROM_NOW, name);
    }

    public static void scheduleBatch(Database.Batchable<sObject> batchable, Integer scopeSize, Integer minutesFromNow, String name) {
        if (Test.isRunningTest()) return;

        String jobName = String.isEmpty(name) ? getClassName(batchable) : name;
        List<CronTrigger> cronTriggers = [SELECT Id, State FROM CronTrigger WHERE CronJobDetail.Name = :jobName];

        if (!isScheduledJob(cronTriggers)) {
            abortDeletedJob(cronTriggers);
            try {
                System.schedule(jobName, getSchString(minutesFromNow), new EUR_CRM_BatchService(batchable, scopeSize, jobName));
            } catch (Exception ex) {
                //Do nothing: Simultaneous case
                System.debug('Schedule Job Error: ' + ex.getMessage());
            }
        }
    }

    private Boolean isRuningBatch(Database.Batchable<sObject> batchable) {
        String jobName = getClassName(batchable);
        List<AsyncApexJob> asyncApexJobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE
            ApexClass.Name = :jobName AND
                Status IN :RUNING_JOB_STATUSES
            LIMIT 1
        ];
        return !asyncApexJobs.isEmpty();
    }

    public static Boolean isScheduledJob(List<CronTrigger> cronTriggers) {
        if(cronTriggers.isEmpty()) return false;
        for(CronTrigger ct : cronTriggers) {
            if(RUNING_CRON_TRIGGER_STATUSES.contains(ct.State)) {
                return true;
            }
        }
        return false;
    }

    public static void abortDeletedJob(List<CronTrigger> cronTriggers) {
        for(CronTrigger ct : cronTriggers) {
            abortJob(ct.Id);
        }
    }

    public static void abortJob(Id jobId) {
        try {
            System.abortJob(jobId);
        } catch (Exception ex) {
            //Do nothing
            System.debug('AbortJob Error: ' + ex.getMessage());
        }
    }

    // Clean freezed jobs (Salesforce bug)
    private static void abortOldJobs() {
        Datetime oldLine = Datetime.now().addMinutes(-(BATCH_WAITING_MINUTES_FROM_NOW + 1)) ;
        List<AsyncApexJob> aajs = [
            SELECT CreatedDate
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'EUR_CRM_BatchService' AND Status = 'Queued'  AND CreatedDate < :oldLine
            ORDER BY CreatedDate
        ];
        if(aajs.isEmpty() && !Test.isRunningTest()) return;

        Map<Id, AsyncApexJob> aajsForAbort = new Map<Id, AsyncApexJob>(aajs);
        for(CronTrigger ct :[
            SELECT CreatedDate
            FROM CronTrigger
            WHERE CreatedDate < :oldLine AND CronJobDetail.JobType = '7'
        ]) {
            for(AsyncApexJob aaj : new List<AsyncApexJob>(aajsForAbort.values())) {
                Long milliSecondsDifference = Math.abs(aaj.CreatedDate.getTime() - ct.CreatedDate.getTime());
                if(milliSecondsDifference <= 1000) {
                    aajsForAbort.remove(aaj.Id);
                }
            }
        }

        for(Id aajId : aajsForAbort.keySet()) {
            abortJob(aajId);
        }
    }

    public static String getSchString(Integer minutesFromNow) {
        Datetime runingTime = Datetime.now().addMinutes(minutesFromNow).addSeconds(2);
        return runingTime.format('s m H d M \'?\' yyyy');
    }

    public static String getClassName(Object obj) {
        return String.valueOf(obj).split(':')[0];
    }

}