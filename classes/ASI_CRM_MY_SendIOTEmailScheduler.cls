global class ASI_CRM_MY_SendIOTEmailScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        ASI_CRM_MY_SendIOTEmailBatch obj = new ASI_CRM_MY_SendIOTEmailBatch();
        DataBase.executeBatch(obj, 5);
    }
}