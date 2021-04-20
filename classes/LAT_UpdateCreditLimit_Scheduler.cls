global class LAT_UpdateCreditLimit_Scheduler implements Schedulable {

	global Id headerId;


	global void execute(SchedulableContext sc) {
		List<AsyncApexJob> listAsyncApexJob = [SELECT id FROM AsyncApexJob 
                                                   WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
        //se chequea el limite de Salesforce, si hay cupo disponible se ejecuta el batch, sino se vuelve a hacer el schedule            
        if (listAsyncApexJob == null || listAsyncApexJob != null && listAsyncApexJob.size() < 5){
        	String[] sizes = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_OWNER_UPDATE_Batch', ' ');
    		Integer batchSize = sizes != null ?  Integer.valueOf(sizes[0]) : 1;
            Database.executeBatch(new LAT_UpdateCreditLimit_Batch(headerId), batchSize);
        }else{                
            DateTime nowTime = datetime.now().addSeconds(65);
            String Seconds = '0';
            String Minutes = String.valueOf(nowTime.minute()).length() == 1 ? '0' + String.valueOf(nowTime.minute()) : String.valueOf(nowTime.minute());
            String Hours = String.valueOf(nowTime.hour()).length() == 1 ? '0' + String.valueOf(nowTime.hour()) : String.valueOf(nowTime.hour());
            String DayOfMonth = String.valueOf(nowTime.day());
            String Month = String.ValueOf(nowTime.month());
            String DayOfweek = '?';
            String optionalYear = String.valueOf(nowTime.year());
            String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
            
            LAT_UpdateCreditLimit_Scheduler scheduleToRun = new LAT_UpdateCreditLimit_Scheduler();
            scheduleToRun.headerId = headerId;    
            String idjob = system.schedule('LAT_UpdateCreditLimit_Scheduler '+system.now(), CronExpression, scheduleToRun);
        }
	}
}