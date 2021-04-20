global class MMPJ_Ext_Vign_BatchDelNotifDocsSCH implements Schedulable {
	global void execute(SchedulableContext ctx) {
        MMPJ_Ext_Vign_BatchDeleteNotifDocs batch1 = new MMPJ_Ext_Vign_BatchDeleteNotifDocs();
        ID batchprocessid = Database.executeBatch(batch1);
    }
}