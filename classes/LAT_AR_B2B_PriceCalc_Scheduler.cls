global class LAT_AR_B2B_PriceCalc_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		
		List<asyncapexjob> liveBatchs = [SELECT id, ApexClass.name, Status  FROM asyncapexjob WHERE JobType='BatchApex' AND Status in ('Processing','Preparing','Queued','Holding')];
		List<LAT_B2B_Price_Configs__c> remaining = [SELECT Name, LAT_Account__c, LAT_InternalId__c, LAT_LastExecution__c FROM LAT_B2B_Price_Configs__c WHERE LAT_LastExecution__c <> TODAY];
		if(remaining.size() > 0) {
			//Execute Batch
			if(liveBatchs.size() < 4){
				LAT_B2B_Price_Configs__c cmt = remaining[0];
				System.debug('%%%%% cmt : ' + cmt);
				LAT_B2B_PriceCalc_Batch b = new LAT_B2B_PriceCalc_Batch(cmt.LAT_InternalId__c); 
				Database.executeBatch(b, 1);

				cmt.LAT_LastExecution__c = Date.Today();
				update cmt;
				if(remaining.size() <> 1) {
        			//Shcedule Next Business Unit Execution
					selfSchedule();
        		}
			} else {
				selfSchedule();
			}
		}
		
	}

	public void selfSchedule(){
		Datetime sysTime = System.now();
		LAT_GeneralConfig__c gc = LAT_GeneralConfig__c.getInstance('AR_B2B_PriceCalcBatchInterval');
		sysTime = sysTime.addSeconds(Integer.valueOf(gc.LAT_Value__c));
		String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		LAT_AR_B2B_PriceCalc_Scheduler scheduler = new LAT_AR_B2B_PriceCalc_Scheduler();
		System.schedule('B2B PriceCalculation ' + sysTime,chron_exp,scheduler);
	}
}