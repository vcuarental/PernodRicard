@isTest
private class LAT_BR_SellOutTaskSchedulerTest {
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';

	@isTest static void testExecute() {

		LAT_BR_SellOutTaskScheduler sotct = new LAT_BR_SellOutTaskScheduler(); 
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
            	Name = 'COLLETA_CREATE_TASKS',
             	LAT_Value__c = 'true');
		insert cfg;

			Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    	insert Acc;
      LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
      rf.Account__c = Acc.id;
      rf.IsActive__c = true;

      insert rf;
      Date vence = Date.today();

		  Test.startTest();
			LAT_BR_SellOutTaskScheduler taskSched = new LAT_BR_SellOutTaskScheduler();
				String jobId = System.schedule('ScheduleApexClassTest',
					                        CRON_EXP, 
					                        taskSched);
				Test.stopTest();
	}
		
}