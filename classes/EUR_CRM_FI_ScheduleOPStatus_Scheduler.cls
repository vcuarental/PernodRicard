global class EUR_CRM_FI_ScheduleOPStatus_Scheduler implements Schedulable {
	
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new EUR_CRM_FI_ScheduleOPStatus());
    }
    
}