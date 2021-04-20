@IsTest
private class EUR_CRM_BatchServiceTest {

    @IsTest
    private static void batchInitTest() {
        new EUR_CRM_BatchService(new EUR_CRM_AccGroupUserSharingBatch(), 1, 'Account Group User Sharing Scheduled Job');
    }

    @IsTest
    private static void schedulerInitTest() {
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_BatchService batchService = new EUR_CRM_BatchService(new EUR_CRM_AccGroupUserSharingBatch(), 1, 'Account Group User Sharing Scheduled Job');
        System.schedule('Batch Service', cronExpression, batchService);
    }

    @IsTest
    private static void scheduleBatchTest() {
        EUR_CRM_BatchService.scheduleBatch(new EUR_CRM_AccGroupUserSharingBatch(), 1);
    }

    @IsTest
    private static void isScheduledJobEmptyListTest() {
        EUR_CRM_BatchService.isScheduledJob(new List<CronTrigger>());
    }

    @IsTest
    private static void isScheduledJobTest() {
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_BatchService batchService = new EUR_CRM_BatchService(new EUR_CRM_AccGroupUserSharingBatch(), 1, 'Account Group User Sharing Scheduled Job');
        System.schedule('Batch Service', cronExpression, batchService);

        EUR_CRM_BatchService.isScheduledJob([SELECT Id, State FROM CronTrigger LIMIT 1]);
    }

    @IsTest
    private static void abortDeletedJobTest() {
        String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
        EUR_CRM_BatchService batchService = new EUR_CRM_BatchService(new EUR_CRM_AccGroupUserSharingBatch(), 1, 'Account Group User Sharing Scheduled Job');
        System.schedule('Batch Service', cronExpression, batchService);

        EUR_CRM_BatchService.abortDeletedJob([SELECT Id, State FROM CronTrigger LIMIT 1]);
    }

    @IsTest
    private static void getSchStringTest() {
        EUR_CRM_BatchService.getSchString(2);
    }

    @IsTest
    private static void getClassNameTest() {
        EUR_CRM_BatchService.getClassName(new EUR_CRM_Account__c());
    }

}