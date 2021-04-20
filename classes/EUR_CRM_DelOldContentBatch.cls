global class EUR_CRM_DelOldContentBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable {

//    Database.executeBatch(new EUR_CRM_DelOldContentBatch(), 100);

//    String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
//    EUR_CRM_DelOldContentBatch scheduledJob = new EUR_CRM_DelOldContentBatch();
//    System.schedule('Delete Expired Content Documents', cronExpression, scheduledJob);

    global EUR_CRM_DelOldContentBatch() {}

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_DelOldContentBatch(), 100);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            ,   ContentDocument.Id
            FROM ContentVersion
            WHERE EUR_CRM_Store_End_Date__c <= YESTERDAY
        ]);
    }

    global void execute(Database.BatchableContext bc, List<ContentVersion> versions) {
        System.debug('\n\n versions.size() => ' + JSON.serializePretty(versions.size()) + '\n');
        System.debug('\n\n versions => ' + JSON.serializePretty(versions) + '\n');

        List<ContentDocument> documentsToDelete = new List<ContentDocument>();

        for (ContentVersion v : versions) {
            documentsToDelete.add(v.ContentDocument);
        }

        this.deleteRecords(documentsToDelete);
    }

}