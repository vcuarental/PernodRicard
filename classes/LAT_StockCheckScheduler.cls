global class LAT_StockCheckScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		 Database.executeBatch(new LAT_UY_StockCheckBatch(), 200);
		 Database.executeBatch(new LAT_AR_StockCheckBatch(), 200);
	}
}