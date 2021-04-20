global class MMPJ_XRM_BatchDeleteSocieteLies_Schedule implements Schedulable {
	global void execute(SchedulableContext ctx) {
        MMPJ_XRM_BatchDeleteSocieteLies batch1 = new MMPJ_XRM_BatchDeleteSocieteLies();
        ID batchprocessid = Database.executeBatch(batch1);
    }
}