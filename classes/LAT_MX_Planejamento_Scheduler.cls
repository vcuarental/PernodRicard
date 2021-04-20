global class LAT_MX_Planejamento_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		 Database.executeBatch(new LAT_MX_Planejamento_Batch(), 20); 
	}
}