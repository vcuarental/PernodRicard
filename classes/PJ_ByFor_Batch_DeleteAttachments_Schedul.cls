global class PJ_ByFor_Batch_DeleteAttachments_Schedul implements Schedulable {
	global void execute(SchedulableContext ctx) {
        PJ_ByFor_Batch_DeleteAttachments bacth1 = new PJ_ByFor_Batch_DeleteAttachments();
        ID batchprocessid = Database.executeBatch(bacth1);
    }
}