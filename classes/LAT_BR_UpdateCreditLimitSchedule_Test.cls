@isTest
private class LAT_BR_UpdateCreditLimitSchedule_Test {
	
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';

	@isTest static void test_method_one() {
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
            	Name = 'UPDATE_CREDIT_LIMIT_MONTHS',
             	LAT_Value__c = '2');

		Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;

        LAT_FiscalNote__c fn = new LAT_FiscalNote__c( Name = 'Test', 
        								LAT_BillingDate__c = Date.today().addMonths(-13),
        								LAT_Client__c = Acc.id );
        insert fn;

		Test.startTest();
			LAT_BR_UpdateCreditLimitSchedule UCLS = new LAT_BR_UpdateCreditLimitSchedule();
			String jobId = System.schedule('ScheduleApexClassTest',
					                        CRON_EXP, 
					                        UCLS);
			// Get the information from the CronTrigger API object
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
								 NextFireTime
								 FROM CronTrigger WHERE id = :jobId];

			// Verify the expressions are the same
			System.assertEquals(CRON_EXP, 
			 					ct.CronExpression);

			// Verify the job has not run
			System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();

	}
	
}