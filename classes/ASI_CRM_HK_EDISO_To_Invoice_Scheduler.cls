global class ASI_CRM_HK_EDISO_To_Invoice_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        ASI_CRM_HK_EDISO_To_Invoice_Batch obj = new ASI_CRM_HK_EDISO_To_Invoice_Batch();
        DataBase.executeBatch(obj, 20);
    }
}