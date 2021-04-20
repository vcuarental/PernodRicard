@IsTest
private class EUR_CRM_Every15MinutesScheduledJobTest {

    @IsTest
    private static void setupScheduledJobTest() {
        Test.startTest();
        EUR_CRM_Every15MinutesScheduledJob.currentDT = Datetime.now();
        EUR_CRM_Every15MinutesScheduledJob.schedulerConfigCMTWrapper = new EUR_CRM_SchedulerConfigCMTWrapper();
        Set<String> cronJobIds = new EUR_CRM_Every15MinutesScheduledJob().setupScheduledJobs();
        Test.stopTest();

        System.assertEquals(4, cronJobIds.size());

        List<CronTrigger> cronTriggers = selectCronTriggers(cronJobIds);
        System.assertEquals(4, cronTriggers.size());

        System.assertEquals('0 0 * * * ?', cronTriggers[0].CronExpression);
        System.assertEquals('0 15 * * * ?', cronTriggers[1].CronExpression);
        System.assertEquals('0 30 * * * ?', cronTriggers[2].CronExpression);
        System.assertEquals('0 45 * * * ?', cronTriggers[3].CronExpression);

        System.assertEquals(0, cronTriggers[0].NextFireTime.minute());
        System.assertEquals(15, cronTriggers[1].NextFireTime.minute());
        System.assertEquals(30, cronTriggers[2].NextFireTime.minute());
        System.assertEquals(45, cronTriggers[3].NextFireTime.minute());

        System.assert(cronTriggers[0].CronJobDetail.Name.containsIgnoreCase('at hh:00'));
        System.assert(cronTriggers[1].CronJobDetail.Name.containsIgnoreCase('at hh:15'));
        System.assert(cronTriggers[2].CronJobDetail.Name.containsIgnoreCase('at hh:30'));
        System.assert(cronTriggers[3].CronJobDetail.Name.containsIgnoreCase('at hh:45'));
    }


    /* ========================================================= */
    /*     Pisitive scenarios
    /* ========================================================= */
    @IsTest
    private static void runScheduledJobAt_0100_RealDataPositiveTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(1, 0, 0, 0));
        System.assertEquals(1, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_AccountEUShareBatch'));
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0200_RealDataPositiveTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(2, 0, 0, 0));
        System.assertEquals(2, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_DelAttachOfInactiveOPBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_DelOldContentBatch'));
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0300_RealDataPositiveTest() {
        insert new EUR_CRM_Account_Target_Group__c(EUR_CRM_IsDynamic__c = true, EUR_CRM_isDailyRecalculation__c = true);

        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(3, 0, 0, 0));
        System.assertEquals(1, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_RefreshDynGroupBatch'));
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0400_RealDataPositiveTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(4, 0, 0, 0));
        System.assertEquals(1, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_AccountGeolocationBatch'));
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0000_OneBatchJobMockDataPositiveTest() {
        Test.startTest();
        executeScheduledJobWithCMTdataMock(new Map<String, Integer> {
            'EUR_CRM_AccountEUShareBatch' => 200
        });

        System.assertEquals(1, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_AccountEUShareBatch'));
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0000_FourBatchJobsMockDataPositiveTest() {
        Test.startTest();
        executeScheduledJobWithCMTdataMock(new Map<String, Integer> {
            'EUR_CRM_AccountEUShareBatch' => 200
        ,   'EUR_CRM_AccountGeolocationBatch' => 100
        ,   'EUR_CRM_DelAttachOfInactiveOPBatch' => 200
        ,   'EUR_CRM_DelOldContentBatch' => 200
        ,   'EUR_CRM_RefreshDynGroupBatch' => 200
        });

        System.assertEquals(4, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_AccountEUShareBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_AccountGeolocationBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_DelAttachOfInactiveOPBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_DelOldContentBatch'));
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0000_FiveBatchJobsMockDataPositiveTest() {
        insert new EUR_CRM_Account_Target_Group__c(EUR_CRM_IsDynamic__c = true, EUR_CRM_isDailyRecalculation__c = true);

        Test.startTest();
        executeScheduledJobWithCMTdataMock(new Map<String, Integer> {
            'EUR_CRM_AccountEUShareBatch' => 200
        ,   'EUR_CRM_AccountGeolocationBatch' => 100
        ,   'EUR_CRM_DelAttachOfInactiveOPBatch' => 200
        ,   'EUR_CRM_DelOldContentBatch' => 200
        ,   'EUR_CRM_RefreshDynGroupBatch' => 200
        });

        System.assertEquals(5, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_AccountEUShareBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_AccountGeolocationBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_DelAttachOfInactiveOPBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_DelOldContentBatch'));
        System.assert(EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.contains('EUR_CRM_RefreshDynGroupBatch'));
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Negative scenarios
    /* ========================================================= */
    @IsTest
    private static void runScheduledJobAt_0115_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(1, 15, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0130_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(1, 30, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0145_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(1, 45, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0215_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(2, 15, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0230_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(2, 30, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0245_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(2, 45, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0300_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(3, 0, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0315_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(3, 15, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0330_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(3, 30, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0345_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(3, 45, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0415_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(4, 15, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0430_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(4, 30, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0445_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(4, 45, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0600_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(6, 0, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0615_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(6, 15, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0630_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(6, 30, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_0645_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(6, 45, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1200_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(12, 0, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1215_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(12, 15, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1230_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(12, 30, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1245_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(12, 45, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1800_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(18, 0, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1815_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(18, 15, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1830_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(18, 30, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }

    @IsTest
    private static void runScheduledJobAt_1845_RealDataNegativeTest() {
        Test.startTest();
        executeScheduledJobWithDatetimeMock(Date.today(), Time.newInstance(18, 45, 0, 0));
        System.assertEquals(0, EUR_CRM_Every15MinutesScheduledJob.runnedBatchJobs.size());
        Test.stopTest();
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static void executeScheduledJobWithDatetimeMock(Date dt, Time tm) {
        EUR_CRM_Every15MinutesScheduledJob.schedulerConfigCMTWrapper = new EUR_CRM_SchedulerConfigCMTWrapper();
        EUR_CRM_Every15MinutesScheduledJob.currentDT = Datetime.newInstance(dt, tm);
        new EUR_CRM_Every15MinutesScheduledJob().execute(null);
    }

    private static void executeScheduledJobWithCMTdataMock(Map<String, Integer> batchSizeByBatchClassName) {
        EUR_CRM_Every15MinutesScheduledJob.schedulerConfigCMTWrapper =
            (EUR_CRM_SchedulerConfigCMTWrapper) EUR_CRM_SchedulerConfigCMTWrapperMock.createMock(batchSizeByBatchClassName);
        EUR_CRM_Every15MinutesScheduledJob.currentDT = Datetime.now();

        new EUR_CRM_Every15MinutesScheduledJob().execute(null);
    }


    /* ========================================================= */
    /*     SOQL Wrappers
    /* ========================================================= */
    private static List<CronTrigger> selectCronTriggers(Set<String> cronJobIds) {
        return [
            SELECT Id
            ,   CronJobDetail.Name
            ,   CronExpression
            ,   NextFireTime
            FROM CronTrigger
            WHERE Id IN :cronJobIds
        ];
    }

}