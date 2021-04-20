global class LAT_CheckPaymentStatusOnME_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {

		database.executebatch(new LAT_CheckPaymentStatusOnME_Batch(), 10);
		database.executebatch(new LAT_Contract_Batch(), 100);

	}
}