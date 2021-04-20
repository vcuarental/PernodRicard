@IsTest
private class EUR_CRM_NightlyScheduledJobsTest {

    @IsTest
    private static void schedulerTest() {
        Test.startTest();
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_NightlyScheduledJobs scheduledJob = new EUR_CRM_NightlyScheduledJobs();
        String jobId = System.schedule('All EMEA nightly sheduled jobs', cronExpression, scheduledJob);
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM CronTrigger WHERE Id = :jobId].size());
    }

}