global class EUR_CRM_Every15MinutesScheduledJob implements Schedulable {

    private final String SCHEDULER_JOB = 'EUR_CRM_Every15MinutesScheduledJob';
    private final Set<String> BATCH_JOBS_WITH_ADDITIONAL_INITIAL_REQUIREMENTS = new Set<String> {
        'EUR_CRM_RefreshDynGroupBatch'
    };

    @TestVisible private static Datetime currentDT = Datetime.now();
    @TestVisible private static EUR_CRM_SchedulerConfigCMTWrapper schedulerConfigCMTWrapper = new EUR_CRM_SchedulerConfigCMTWrapper();
    @TestVisible private static Set<String> runnedBatchJobs = new Set<String>();

    public Set<String> setupScheduledJobs() {
        EUR_CRM_Every15MinutesScheduledJob scheduledJob = new EUR_CRM_Every15MinutesScheduledJob();

        Set<String> cronJobIds = new Set<String>();
        cronJobIds.add(System.schedule(SCHEDULER_JOB + ': at hh:00', '0 0 * * * ?', scheduledJob));
        cronJobIds.add(System.schedule(SCHEDULER_JOB + ': at hh:15', '0 15 * * * ?', scheduledJob));
        cronJobIds.add(System.schedule(SCHEDULER_JOB + ': at hh:30', '0 30 * * * ?', scheduledJob));
        cronJobIds.add(System.schedule(SCHEDULER_JOB + ': at hh:45', '0 45 * * * ?', scheduledJob));
        return cronJobIds;
    }


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    global void execute(SchedulableContext sc) {
        Map<String, Integer> batchSizeByBatchClassName = schedulerConfigCMTWrapper.getBatchSizeByBatchClassName(SCHEDULER_JOB, currentDT);
        System.debug('\n\n batchSizeByBatchClassName.size() => ' + JSON.serializePretty(batchSizeByBatchClassName.size()) + '\n');
        System.debug('\n\n batchSizeByBatchClassName => ' + JSON.serializePretty(batchSizeByBatchClassName) + '\n');
        if (batchSizeByBatchClassName.isEmpty()) { return ; }

        for (String batchClassName : batchSizeByBatchClassName.keySet()) {
            if (this.isNeedToRunBatchJob(batchClassName)) {
                this.runBatchJob(batchClassName, batchSizeByBatchClassName.get(batchClassName));
            }
        }
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void runBatchJob(String batchClassName, Integer batchSize) {
        if (Test.isRunningTest()) {
            runnedBatchJobs.add(batchClassName);
        } else {
            System.debug('\n\n Run: ' + batchClassName + '\n');
            Database.executeBatch((Database.Batchable<SObject>) Type.forName(batchClassName).newInstance(), batchSize);
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Boolean isNeedToRunBatchJob(String batchClassName) {
        if (this.isBatchJobWithoutAdditionalRequirements(batchClassName)) { return true; }

        if (batchClassName.equalsIgnoreCase('EUR_CRM_RefreshDynGroupBatch')) {
            return this.isNeedToRun_EUR_CRM_RefreshDynGroupBatch();
        }

        return false;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Boolean isNeedToRun_EUR_CRM_RefreshDynGroupBatch() {
        return ! this.selectOneDynamicATGforDailyRecalculation().isEmpty();
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isBatchJobWithoutAdditionalRequirements(String batchClassName) {
        return ! BATCH_JOBS_WITH_ADDITIONAL_INITIAL_REQUIREMENTS.contains(batchClassName);
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Account_Target_Group__c> selectOneDynamicATGforDailyRecalculation() {
        return [
            SELECT Id
            FROM EUR_CRM_Account_Target_Group__c
            WHERE EUR_CRM_isDailyRecalculation__c = TRUE
                AND EUR_CRM_IsDynamic__c = TRUE
            LIMIT 1
        ];
    }

}