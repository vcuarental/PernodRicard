@isTest
private class LAT_ADM_MonitorCalloutsEmailTest {
	
	@isTest static void testSendEmailIfCritical() {
		setUp();
		LAT_ADM_MonitorCalloutsEmail e = new LAT_ADM_MonitorCalloutsEmail();
		System.assertEquals(false, e.isCritical(10, 5, 150, 80));
		System.assertEquals(true, e.sendEmailIfCritical());
	}
	
	@isTest static void testIsCritical() {
		LAT_ADM_MonitorCalloutsEmail e = new LAT_ADM_MonitorCalloutsEmail();
		System.assertEquals(false, e.isCritical(10, 5, 150, 80));
	}

	@isTest static void testScheduler() {
		setUp();
		LAT_ADM_MonitorCalloutsSchedule e = new LAT_ADM_MonitorCalloutsSchedule();
		e.execute(null);
	}



	public static void setUp() {
        // Insert an email to deliver
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
        	Name = 'MONITOR_CALLOUT_RECEIPT',
        	LAT_Value__c = 'diego.salido@pernod-ricard.com');
        insert cfg;

        // Insert service config
        cfg = new LAT_GeneralConfig__c(
        	Name = 'MONITOR_CALLOUT_OPTIONS',
        	LAT_Value__c = '5,5,100,60');
        insert cfg;

        for (Integer i = 0; i < 10; i++) {
	        LAT_Log__c l = new LAT_Log__c(
	        	LAT_StartTime__c = Datetime.now().addMinutes(-3),
	        	LAT_ReturnTime__c = Datetime.now().addMinutes(-1)
	        	);
	        insert l;
	    }
	}
	
}