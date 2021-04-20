global class MMPJ_XRM_BatchCalculateSegmentation_Sch implements Schedulable {

    global void execute(SchedulableContext sc) {
        MMPJ_XRM_BatchCalculateSegmentation bacth = new MMPJ_XRM_BatchCalculateSegmentation();
        Id batchprocessid = Database.executeBatch(bacth);
    }
}