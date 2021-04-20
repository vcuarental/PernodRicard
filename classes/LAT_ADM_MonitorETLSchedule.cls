global class LAT_ADM_MonitorETLSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		LAT_ADM_MonitorETLEmail e = new LAT_ADM_MonitorETLEmail();
		e.sendStatusEmail();
	}
}