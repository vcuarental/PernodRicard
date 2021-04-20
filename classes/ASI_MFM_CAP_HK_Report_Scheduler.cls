global class ASI_MFM_CAP_HK_Report_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        ASI_MFM_CAP_HK_MonthEnd_Report b = new ASI_MFM_CAP_HK_MonthEnd_Report();
        database.executeBatch(b, 10);
    }
}