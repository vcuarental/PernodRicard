global class LAT_ProcessesInventoryScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		LAT_CLIENTPOP.automaticInventory();
	}
}