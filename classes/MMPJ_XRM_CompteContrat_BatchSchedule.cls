global class MMPJ_XRM_CompteContrat_BatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        MMPJ_XRM_BatchCompteContrat bacth1 = new MMPJ_XRM_BatchCompteContrat();
        ID batchprocessid = Database.executeBatch(bacth1);
    }
}