@isTest
private class LAT_ProcessesTasksScheduler_Test {
	public static String CRON_EXP = '0 0 0 3 9 ? 2022';
	
	@isTest static void testExecute() {
			Account a = accountCreator();
			User manager = TestFactory.createUserWithProfile('Vendas1', 'Vendas');
			insert manager;
			User u = TestFactory.createUserWithProfile('Vendas2', 'Vendas');
			u.managerId = manager.id;
			insert u;
			

			String rec = Global_RecordTypeCache.getRtId('Task'+'LAT_POP');
			Integer days = Integer.valueOf('3');
			Task t = LAT_ProcessesTaks.createTask(a.id,u.id,'ABC','123',rec,days,'Coletar');
			t.ActivityDate = Date.today().addDays(-1);
			insert t;
			LAT_ProcessesTasksScheduler taskSched = new LAT_ProcessesTasksScheduler();
			String jobId = System.schedule('ScheduleApexClassTest',
					                        CRON_EXP, 
					                        taskSched);
	}
	public static Account accountCreator(){
  
      Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
  	  insert Acc;
  	  return Acc;
  }
	
	
}