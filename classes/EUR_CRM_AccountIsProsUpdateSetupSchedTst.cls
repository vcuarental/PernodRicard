@IsTest
private class EUR_CRM_AccountIsProsUpdateSetupSchedTst {

    @IsTest
    private static void testScheduledJob() {
        Test.startTest();

        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_AccountIsProsUpdateSetupBatch scheduledJob = new EUR_CRM_AccountIsProsUpdateSetupBatch();
        String jobId = System.schedule('Account Is Pros Updated Scheduled Job', cronExpression, scheduledJob);

        Test.stopTest();

        List<CronTrigger> cronTriggers = selectCronTriggersWhereJobId(jobId);
        System.assertEquals(1, cronTriggers.size());

        System.assertEquals(cronExpression, cronTriggers[0].CronExpression);
        System.assertEquals(0, cronTriggers[0].TimesTriggered);
        System.assertNotEquals(null, cronTriggers[0].NextFireTime);
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<CronTrigger> selectCronTriggersWhereJobId(Id jobId) {
        return [
            SELECT Id
            ,   CronExpression
            ,   TimesTriggered
            ,   NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
    }

}