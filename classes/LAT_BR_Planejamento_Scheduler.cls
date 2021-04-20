global class LAT_BR_Planejamento_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		 Database.executeBatch(new LAT_BR_Planejamento_Batch(), 20); 
	}
}