trigger LAT_CreditLimitUpdate on LAT_MasiveCreditLineHeader__c (after update) {

	if(trigger.isAfter){
		if(trigger.isUpdate){
			for(integer i =0; i < trigger.new.size(); i++){
				if(trigger.new[0].LAT_Status__c == 'En ejecucion' && trigger.old[0].LAT_Status__c == 'En aprobacion' ){
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
            		scheduleToRun.headerId = trigger.new[0].Id;    

            		String idjob = system.schedule('LAT_UpdateCreditLimit_Scheduler '+system.now(), CronExpression, scheduleToRun);
				}
			}

		}
	}

}