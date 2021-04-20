global class ASI_CRM_MY_CloneAllRSPScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        ASI_CRM_MY_CloneAllRSPBatch obj = new ASI_CRM_MY_CloneAllRSPBatch();
        DataBase.executeBatch(obj, 50);
    }
}