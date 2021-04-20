global class EUR_CRM_DelAttachOfInactiveOPBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject>, Schedulable {

//    Database.executeBatch(new EUR_CRM_DelAttachOfInactiveOPBatch(), 100);

//    String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
//    EUR_CRM_DelAttachOfInactiveOPBatch scheduledJob = new EUR_CRM_DelAttachOfInactiveOPBatch();
//    System.schedule('Delete NotesAndAttachments for old OPs', cronExpression, scheduledJob);

    private final Set<String> ACCOUNT_STATUSES = new Set<String> {
        'Ended'
    ,   'Deactivated'
    };

    global EUR_CRM_DelAttachOfInactiveOPBatch() {}

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_DelAttachOfInactiveOPBatch(), 100);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
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
            WHERE EUR_CRM_Status__c IN :ACCOUNT_STATUSES
        ]);
    }

    global void execute(Database.BatchableContext bc, List<EUR_CRM_Objectives_Promotions__c> objectivesPromotions) {
        System.debug('\n\n objectivesPromotions.size() => ' + JSON.serializePretty(objectivesPromotions.size()) + '\n');
        System.debug('\n\n objectivesPromotions => ' + JSON.serializePretty(objectivesPromotions) + '\n');

        List<Attachment> attachmentsToDelete = new List<Attachment>();
        List<Note> notesToDelete = new List<Note>();

        for (EUR_CRM_Objectives_Promotions__c op : objectivesPromotions) {
            attachmentsToDelete.addAll(op.Attachments);
            notesToDelete.addAll(op.Notes);
        }

        this.deleteRecords(attachmentsToDelete);
        this.deleteRecords(notesToDelete);
    }

}