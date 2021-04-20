global class LAT_BR_TrafficLightSchedule implements Schedulable {

	Integer bStep;
	Integer eStep;
	Integer bSize;

	Integer year;
	Integer month;

	global LAT_BR_TrafficLightSchedule(Integer batchStep, Integer stepsToRun, Integer batchSize, Integer month, Integer year) {
		this.bStep = batchStep;
		this.bSize = batchSize;
		this.eStep = stepsToRun;

		this.year = year;
		this.month = month;
	}

	global void execute(SchedulableContext sc) {
		LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(this.bStep, this.eStep, this.month, this.year);
		Database.executeBatch(tlb, this.bSize);
	}

}