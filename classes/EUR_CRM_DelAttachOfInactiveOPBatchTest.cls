@IsTest
private class EUR_CRM_DelAttachOfInactiveOPBatchTest {

    @TestSetup
    private static void setupMethod() {
        List<EUR_CRM_Objectives_Promotions__c> objectivesPromotions = new List<EUR_CRM_Objectives_Promotions__c>();
        objectivesPromotions.add(makeObjectivesPromotions('Ended'));
        objectivesPromotions.add(makeObjectivesPromotions('Active'));
        insert objectivesPromotions;

        List<Attachment> attachments = new List<Attachment>();
        List<Note> notes = new List<Note>();
        for(EUR_CRM_Objectives_Promotions__c op : objectivesPromotions) {
            attachments.add(makeAttachment(op.Id));
            notes.add(makeNote(op.Id));
        }
        insert attachments;
        insert notes;
    }

    @IsTest
    private static void setupTest() {
        List<EUR_CRM_Objectives_Promotions__c> objectivesPromotions = selectObjectivesPromotions();
        System.assertEquals(2, objectivesPromotions.size());

        for (EUR_CRM_Objectives_Promotions__c op : objectivesPromotions) {
            System.assertEquals(1, op.Attachments.size());
            System.assertEquals(1, op.Notes.size());
        }
    }


    @IsTest
    static void simplePositiveTest() {
        Test.startTest();
        Database.executeBatch(new EUR_CRM_DelAttachOfInactiveOPBatch());
        Test.stopTest();

        List<EUR_CRM_Objectives_Promotions__c> objectivesPromotions = selectObjectivesPromotions();
        System.assertEquals(2, objectivesPromotions.size());

        System.assertEquals(0, objectivesPromotions[0].Attachments.size());
        System.assertEquals(0, objectivesPromotions[0].Notes.size());

        System.assertEquals(1, objectivesPromotions[1].Attachments.size());
        System.assertEquals(1, objectivesPromotions[1].Notes.size());
    }

    @IsTest
    static void scheduleTest() {
        String cronExpression = '0 0 3 * * ?';
        EUR_CRM_DelAttachOfInactiveOPBatch scheduledJob = new EUR_CRM_DelAttachOfInactiveOPBatch();

        Test.startTest();
        String jobId = System.schedule('Test: Delete NotesAndAttachments for old OPs', cronExpression, scheduledJob);
        Test.stopTest();

        List<CronTrigger> cronTriggers = selectCronTriggers(jobId);
        System.assertEquals(1, cronTriggers.size());
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static EUR_CRM_Objectives_Promotions__c makeObjectivesPromotions(String status) {
        return new EUR_CRM_Objectives_Promotions__c(
            Name = 'Test'
        ,   EUR_CRM_Status__c = status
        );
    }

    private static Note makeNote(Id opId) {
        return new Note(
            ParentId = opId
        ,   Title = 'Test Title'
        ,   Body = 'Test Body'
        );
    }

    private static Attachment makeAttachment(Id opId) {
        return new Attachment(
            ParentId = opId
        ,   Name = 'Test Name'
        ,   Body = Blob.valueOf('Test Body')
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions() {
        return [
            SELECT Id
            ,   (
                SELECT Id
                FROM Attachments
            )
            ,   (
                SELECT Id
                FROM Notes
            )
            FROM EUR_CRM_Objectives_Promotions__c
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