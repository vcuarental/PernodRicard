global class MMPJ_XRM_BatchSuppAnnuelleContratSCH implements Schedulable {
    public static void createPlanif()
    {
        String jobID = system.schedule('MMPJ_XRM_BatchSuppAnnuelleContratSCH Job', '0 0 2 21 7 ? *', new MMPJ_XRM_BatchSuppAnnuelleContratSCH());
    }

    global void execute(SchedulableContext sc) {
        MMPJ_XRM_BatchSuppAnnuelleContrat bacth1 = new MMPJ_XRM_BatchSuppAnnuelleContrat();
        ID batchprocessid = Database.executeBatch(bacth1);
    }
}