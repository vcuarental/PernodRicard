global class LAT_ADM_MonitorCalloutsSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		LAT_ADM_MonitorCalloutsEmail e = new LAT_ADM_MonitorCalloutsEmail();
		e.sendEmailIfCritical();
	}
}