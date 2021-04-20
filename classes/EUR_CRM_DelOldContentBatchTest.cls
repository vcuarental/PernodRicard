@IsTest
private class EUR_CRM_DelOldContentBatchTest {

    @TestSetup
    private static void setupMethod() {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        contentVersions.add(makeContentVersion(Date.today()));
        contentVersions.add(makeContentVersion(Date.today().addDays(-1)));
        insert contentVersions;
    }

    @IsTest
    private static void setupTest() {
        List<ContentVersion> contentVersions = selectContentVersions();
        System.assertEquals(2, contentVersions.size());
    }


    @IsTest
    static void simplePositiveTest() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_DelOldContentBatch());
        Test.stopTest();

        List<ContentVersion> contentVersions = selectContentVersions();
        System.assertEquals(1, contentVersions.size());
        System.assertEquals(Date.today(), contentVersions[0].EUR_CRM_Store_End_Date__c);
    }

    @IsTest
    static void scheduleTest() {
        String cronExpression = '0 0 3 * * ?';
        EUR_CRM_DelOldContentBatch scheduledJob = new EUR_CRM_DelOldContentBatch();

        Test.startTest();
        String jobId = System.schedule('Test: Delete NotesAndAttachments for old OPs', cronExpression, scheduledJob);
        Test.stopTest();

        List<CronTrigger> cronTriggers = selectCronTriggers(jobId);
        System.assertEquals(1, cronTriggers.size());
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static ContentVersion makeContentVersion(Date endDate){
        return new ContentVersion(
            Title = 'test'
        ,   VersionData = Blob.valueOf('Test Content')
        ,   IsMajorVersion = true
        ,   PathOnClient = 'test.jpg'
        ,   EUR_CRM_Store_End_Date__c = endDate
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<ContentVersion> selectContentVersions(){
        return [
            SELECT Id
            ,   EUR_CRM_Store_End_Date__c
            FROM ContentVersion
        ];
    }

    private static List<CronTrigger> selectCronTriggers(String jobId){
        return [
            SELECT Id
            FROM CronTrigger
            WHERE Id = :jobId
        ];
    }

}